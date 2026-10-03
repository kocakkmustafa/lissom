"""Source guard regressions; these do not execute Gradle or accept a binary."""
import unittest
from pathlib import Path

from release_signing_check import check


GOOD = '''
val hasRealSigning = keyProps.getProperty("storeFile") != null
val allowDebugSigning = providers.gradleProperty("allowDebugSigning").orNull == "true"
buildTypes {
    release {
        when {
            hasRealSigning -> signingConfig = signingConfigs.getByName("release")
            allowDebugSigning -> {
                signingConfig = signingConfigs.getByName("debug")
                logger.warn("Local debug signing; not a store artifact")
            }
            else -> signingConfig = null
        }
    }
}
if (!hasRealSigning && !allowDebugSigning) {
    gradle.taskGraph.whenReady {
        val graph = this
        if (graph.allTasks.any { task ->
            task.project == project && task.name.contains("Release", ignoreCase = true)
        }) {
            throw GradleException("Release signing unavailable")
        }
    }
}
'''

OLD = '''
val hasRealSigning = keyProps.getProperty("storeFile") != null
buildTypes {
        release {
            val allowDebugSigning = project.hasProperty("allowDebugSigning")
            val wantsRelease = gradle.startParameter.taskNames.any {
                it.contains("Release") || it.contains("bundle")
            }
            when {
                hasRealSigning -> signingConfig = signingConfigs.getByName("release")
                allowDebugSigning -> {
                    signingConfig = signingConfigs.getByName("debug")
                    logger.warn("Local debug signing")
                }
                wantsRelease -> throw GradleException("Release signing unavailable")
                else -> signingConfig = signingConfigs.getByName("debug")
            }
        }
}
'''


class SigningSourceGuardTests(unittest.TestCase):
    def test_explicit_true_actual_graph_positive_control(self):
        self.assertEqual(check(GOOD), [])

    def test_current_gradle_source_is_guarded(self):
        source = (Path(__file__).resolve().parents[1] /
                  'android/app/build.gradle.kts').read_text()
        self.assertEqual(check(source), [])

    def test_explicit_parameter_when_ready_is_not_valid_kotlin_dsl_receiver(self):
        source = GOOD.replace('gradle.taskGraph.whenReady {\n        val graph = this',
                              'gradle.taskGraph.whenReady { graph ->')
        self.assertTrue(check(source))

    def test_exact_old_presence_and_requested_name_source_is_rejected(self):
        self.assertTrue(check(OLD))

    def test_true_optin_alone_does_not_fix_old_requested_name_guard(self):
        source = OLD.replace('project.hasProperty("allowDebugSigning")',
                             'providers.gradleProperty("allowDebugSigning").orNull == "true"')
        self.assertTrue(check(source))

    def test_presence_only_optin_is_rejected(self):
        source = GOOD.replace(
            'providers.gradleProperty("allowDebugSigning").orNull == "true"',
            'project.hasProperty("allowDebugSigning")')
        self.assertTrue(check(source))

    def test_false_empty_or_case_variant_are_not_true_optins(self):
        # A source accepting any one of these literals is the wrong policy.
        for wrong in ['false', '', 'TRUE']:
            with self.subTest(wrong=wrong):
                source = GOOD.replace('orNull == "true"', f'orNull == "{wrong}"')
                self.assertTrue(check(source))

    def test_requested_name_guard_cannot_cover_generic_or_wrapper_graph(self):
        source = GOOD.replace(
            'graph.allTasks.any { task ->\n'
            '            task.project == project && task.name.contains("Release", ignoreCase = true)',
            'gradle.startParameter.taskNames.any { name ->\n'
            '            name.contains("Release") || name.contains("bundle")')
        self.assertTrue(check(source))

    def test_missing_graph_guard_is_rejected(self):
        self.assertTrue(check(GOOD.split('if (!hasRealSigning')[0]))

    def test_graph_must_be_scoped_to_this_app_project(self):
        source = GOOD.replace('task.project == project && ', '')
        self.assertTrue(check(source))

    def test_no_optin_release_must_not_fall_back_to_debug(self):
        source = GOOD.replace('else -> signingConfig = null',
                              'else -> signingConfig = signingConfigs.getByName("debug")')
        self.assertTrue(check(source))

    def test_guard_requires_both_unavailable_signing_and_no_optin(self):
        for broken in ['if (!hasRealSigning)', 'if (!allowDebugSigning)',
                       'if (hasRealSigning && !allowDebugSigning)']:
            with self.subTest(broken=broken):
                self.assertTrue(check(GOOD.replace(
                    'if (!hasRealSigning && !allowDebugSigning)', broken)))

    def test_missing_real_signing_and_warning_are_rejected(self):
        for missing in ['signingConfigs.getByName("release")', 'logger.warn(']:
            with self.subTest(missing=missing):
                self.assertTrue(check(GOOD.replace(missing, 'removed(')))

    def test_comments_cannot_supply_guard_markers(self):
        self.assertTrue(check('\n'.join('// ' + line for line in GOOD.splitlines())))


if __name__ == '__main__':
    unittest.main()
