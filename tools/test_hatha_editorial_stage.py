"""Bounded h08 translation staging; never publishes the live course."""
import copy
import hashlib
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest import mock

import build_hatha_course as hatha

PARENT_SHA = 'be597ebcb4d9a3ae05410e2b33752b061bdc4ad1aea49896ae978733b7405a3c'
OVERLAY_SHA = '6a6214d4ccd19f2a5e37aaa83c5d6f1d32c3d7f52b5994373813189161c28f8c'
CANDIDATE_SHA = '746a0a0be7f1791bac84824e79c8c95b54149a2e64185b7137fcf57d5ae7ec07'
OLD = 'Kolları savurmadan üç dönüş çifti yap.'
NEW = 'Kolları savurmadan, yönleri sırayla değiştirerek toplam üç dönüş yap.'


class EditorialStageTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(dir=os.environ.get('HATHA_TEST_STAGING_ROOT'))
        self.addCleanup(self.temp.cleanup)
        self.workspace = Path(self.temp.name).resolve() / 'workspace'
        self.app = self.workspace / 'ventures/lissom/app'
        self.scratch = self.workspace / 'scratch'
        self.app.mkdir(parents=True)
        self.scratch.mkdir()
        # render_v8l reads this attribution relative to ROOT. Keep real parent
        # generation in the fake workspace rather than replacing it with a mock.
        (self.app / 'tools').mkdir()
        (self.app / 'tools/hatha_source_attribution.v2.json').write_bytes(
            (hatha.ROOT / 'tools/hatha_source_attribution.v2.json').read_bytes())
        self.parent = hatha.render().encode('utf-8')
        course = json.loads(self.parent)
        english = course['modules'][1]['lessons'][1]['practice']['en']
        self.overlay = {
            'schemaVersion': 1,
            'status': 'LOCAL_EDITORIAL_PREVIEW_NOT_PUBLISHED',
            'editorialLayer': 'v8n-proposal',
            'parentCourseSha256': PARENT_SHA,
            'parentOverlaySha256': '43acb804f9bf86775706df300a29251af5ca347058e1927acdd3541574d74b83',
            'candidateCourseSha256': CANDIDATE_SHA,
            'publicationVersion': 'UNDECIDED_CENTER',
            'lessonTextEdits': {'h08': {'practice': {'tr': {'from': OLD, 'to': NEW}}}},
            'doseAuthority': 'Existing authored English total of three alternating turns; translation parity only, no new clinical dose.',
            'unchangedEnglish': english,
        }
        self.path = self.scratch / 'h08-overlay.json'
        self.output = self.scratch / 'candidate/hatha.v1.json'
        self.store()
        patch = mock.patch.object(hatha, 'ROOT', self.app)
        patch.start()
        self.addCleanup(patch.stop)

    def store(self):
        self.path.write_text(json.dumps(self.overlay, ensure_ascii=False, indent=2) + '\n',
                             encoding='utf-8')

    def assertRejectedEdit(self, edits):
        self.overlay['lessonTextEdits'] = edits
        self.store()
        with self.assertRaises(ValueError):
            hatha.render_editorial_stage(self.path)

    def test_exact_overlay_and_candidate_with_59_lesson_noninterference(self):
        self.assertEqual(hashlib.sha256(self.path.read_bytes()).hexdigest(), OVERLAY_SHA)
        rendered = hatha.render_editorial_stage(self.path).encode('utf-8')
        self.assertEqual(len(rendered), 270969)
        self.assertEqual(hashlib.sha256(rendered).hexdigest(), CANDIDATE_SHA)
        before, after = json.loads(self.parent), json.loads(rendered)
        expected = copy.deepcopy(before)
        expected['modules'][1]['lessons'][1]['practice']['tr'] = (
            expected['modules'][1]['lessons'][1]['practice']['tr'].replace(OLD, NEW, 1))
        self.assertEqual(after, expected)
        old = [x for m in before['modules'] for x in m['lessons']]
        new = [x for m in after['modules'] for x in m['lessons']]
        self.assertEqual([x['id'] for x in old], [x['id'] for x in new])
        self.assertEqual(sum(a == b for a, b in zip(old, new)), 59)
        self.assertEqual(old[29], new[29])
        self.assertEqual(old[7]['practice']['en'], new[7]['practice']['en'])
        self.assertEqual(before['sourceScopes'], after['sourceScopes'])
        self.assertEqual(before['sources'], after['sources'])
        self.assertEqual(after['version'], '1.0.1')
        self.assertEqual(hatha.render().encode('utf-8'), self.parent)

    def test_cli_write_check_is_scratch_only_and_default_render_unchanged(self):
        original_output = self.scratch / 'live-control.json'
        original_output.write_bytes(self.parent)
        with mock.patch.object(hatha, 'OUTPUT', original_output):
            hatha.main(['--write', '--output', str(self.output),
                        '--editorial-overlay', str(self.path)])
            hatha.main(['--check', '--output', str(self.output),
                        '--editorial-overlay', str(self.path)])
            hatha.main(['--check'])
            hatha.main(['--write'])
        self.assertEqual(original_output.read_bytes(), self.parent)
        self.assertEqual(hashlib.sha256(self.output.read_bytes()).hexdigest(), CANDIDATE_SHA)

    def test_overlay_requires_explicit_output_for_write_and_check(self):
        for mode in ['--write', '--check']:
            with self.subTest(mode=mode), self.assertRaises(ValueError):
                hatha.main([mode, '--editorial-overlay', str(self.path)])

    def test_wrong_parent_course_pin_is_rejected(self):
        self.overlay['parentCourseSha256'] = '0' * 64
        self.store()
        with self.assertRaises(ValueError):
            hatha.render_editorial_stage(self.path)

    def test_changed_rendered_parent_is_rejected(self):
        with mock.patch.object(hatha, 'render', return_value=self.parent.decode() + ' '):
            with self.assertRaises(ValueError):
                hatha.render_editorial_stage(self.path)

    def test_wrong_parent_overlay_pin_is_rejected(self):
        self.overlay['parentOverlaySha256'] = '0' * 64
        self.store()
        with self.assertRaises(ValueError):
            hatha.render_editorial_stage(self.path)

    def test_schema_status_layer_and_publication_version_are_pinned(self):
        for key, value in [('schemaVersion', True), ('status', 'PUBLISHED'),
                           ('editorialLayer', 'v8n'), ('publicationVersion', '1.0.2')]:
            with self.subTest(key=key):
                original = self.overlay[key]
                self.overlay[key] = value
                self.store()
                with self.assertRaises(ValueError):
                    hatha.render_editorial_stage(self.path)
                self.overlay[key] = original

    def test_only_h08_turkish_practice_may_change(self):
        edit = {'from': OLD, 'to': NEW}
        for edits in [
                {'h07': {'practice': {'tr': edit}}},
                {'h30': {'practice': {'tr': edit}}},
                {'h08': {'practice': {'en': edit}}},
                {'h08': {'practice': {'tr': edit, 'en': edit}}},
                {'h08': {'objective': {'tr': edit}}}]:
            with self.subTest(edits=edits):
                self.assertRejectedEdit(edits)

    def test_extra_root_edit_field_is_rejected(self):
        self.overlay['sourceIds'] = ['new-source']
        self.store()
        with self.assertRaises(ValueError):
            hatha.render_editorial_stage(self.path)

    def test_old_and_new_wording_and_dose_are_exact(self):
        for old, new in [('missing old wording', NEW), (OLD, NEW + '!'),
                         (OLD, NEW.replace('üç', 'altı'))]:
            with self.subTest(old=old, new=new):
                self.assertRejectedEdit({'h08': {'practice': {'tr': {'from': old, 'to': new}}}})

    def test_english_and_dose_authority_metadata_are_exact(self):
        for key in ['unchangedEnglish', 'doseAuthority']:
            with self.subTest(key=key):
                original = self.overlay[key]
                self.overlay[key] += '!'
                self.store()
                with self.assertRaises(ValueError):
                    hatha.render_editorial_stage(self.path)
                self.overlay[key] = original

    def test_candidate_digest_mismatch_is_rejected(self):
        self.overlay['candidateCourseSha256'] = '0' * 64
        self.store()
        with self.assertRaises(ValueError):
            hatha.render_editorial_stage(self.path)

    def test_overlay_raw_byte_tampering_is_rejected(self):
        self.path.write_bytes(self.path.read_bytes() + b' ')
        with self.assertRaises(ValueError):
            hatha.render_editorial_stage(self.path)

    def test_duplicate_json_keys_are_rejected(self):
        self.path.write_text('{"schemaVersion":1,"schemaVersion":1}', encoding='utf-8')
        with self.assertRaises(ValueError):
            hatha.render_editorial_stage(self.path)

    def test_failed_validation_preserves_existing_output(self):
        self.output.parent.mkdir()
        self.output.write_bytes(b'keep staged file')
        self.overlay['parentCourseSha256'] = '0' * 64
        self.store()
        with self.assertRaises(ValueError):
            hatha.main(['--write', '--output', str(self.output),
                        '--editorial-overlay', str(self.path)])
        self.assertEqual(self.output.read_bytes(), b'keep staged file')

    def test_check_refuses_different_candidate_bytes(self):
        self.output.parent.mkdir()
        self.output.write_bytes(self.parent)
        with self.assertRaises(ValueError):
            hatha.main(['--check', '--output', str(self.output),
                        '--editorial-overlay', str(self.path)])
        self.assertEqual(self.output.read_bytes(), self.parent)

    def test_external_and_traversal_input_or_output_are_rejected(self):
        external = self.workspace / 'outside.json'
        external.write_bytes(self.path.read_bytes())
        for path in [external, self.scratch / '../outside.json',
                     self.scratch / 'sub/../candidate.json']:
            with self.subTest(path=path), self.assertRaises(ValueError):
                hatha.staged_output(path)
        with self.assertRaises(ValueError):
            hatha.render_editorial_stage(external)
        with self.assertRaises(ValueError):
            hatha.main(['--write', '--output', str(self.app / 'course.json'),
                        '--editorial-overlay', str(self.path)])

    def test_symlink_input_and_output_leaf_are_rejected(self):
        link = self.scratch / 'link.json'
        link.symlink_to(self.path)
        with self.assertRaises(ValueError):
            hatha.render_editorial_stage(link)
        with self.assertRaises(ValueError):
            hatha.main(['--write', '--output', str(link),
                        '--editorial-overlay', str(self.path)])
        self.assertEqual(hashlib.sha256(self.path.read_bytes()).hexdigest(), OVERLAY_SHA)

    def test_even_inside_scratch_symlink_ancestor_is_rejected(self):
        target = self.scratch / 'real-directory'
        target.mkdir()
        link = self.scratch / 'alias'
        link.symlink_to(target, target_is_directory=True)
        with self.assertRaises(ValueError):
            hatha.staged_output(link / 'candidate.json')

    def test_external_symlink_ancestor_is_rejected(self):
        link = self.scratch / 'alias'
        link.symlink_to(self.app, target_is_directory=True)
        with self.assertRaises(ValueError):
            hatha.staged_output(link / 'candidate.json')

    def test_directory_is_not_a_staged_file_destination(self):
        with self.assertRaises(ValueError):
            hatha.staged_output(self.scratch)
        directory = self.scratch / 'a-directory'
        directory.mkdir()
        with self.assertRaises(ValueError):
            hatha.staged_output(directory)

    def test_symlink_parent_swap_after_resolution_cannot_write_outside(self):
        self.output.parent.mkdir()
        replaced = self.scratch / 'original-parent'
        original_resolver = hatha.staged_output

        def swap(path):
            destination = original_resolver(path)
            self.output.parent.rename(replaced)
            self.output.parent.symlink_to(self.app, target_is_directory=True)
            return destination

        with mock.patch.object(hatha, 'staged_output', side_effect=swap):
            with self.assertRaises(OSError):
                hatha._write_staged_bytes(self.output, b'must not escape')
        self.assertFalse((self.app / self.output.name).exists())
        self.assertEqual(list(replaced.iterdir()), [])

    def test_workspace_ancestor_swap_cannot_create_external_scratch(self):
        external = self.workspace.parent / 'outside'
        external.mkdir()
        replaced = self.workspace.parent / 'original-workspace'
        original_resolver = hatha.staged_output

        def swap(path):
            destination = original_resolver(path)
            self.workspace.rename(replaced)
            self.workspace.symlink_to(external, target_is_directory=True)
            return destination

        with mock.patch.object(hatha, 'staged_output', side_effect=swap):
            with self.assertRaises(OSError):
                hatha._write_staged_bytes(self.output, b'must not escape')
        self.assertEqual(list(external.iterdir()), [])

    def test_atomic_stage_does_not_truncate_external_hardlink_target(self):
        external = self.app / 'keep.json'
        external.write_bytes(b'keep external inode')
        self.output.parent.mkdir()
        self.output.hardlink_to(external)
        hatha.main(['--write', '--output', str(self.output),
                    '--editorial-overlay', str(self.path)])
        self.assertEqual(external.read_bytes(), b'keep external inode')
        self.assertEqual(hashlib.sha256(self.output.read_bytes()).hexdigest(), CANDIDATE_SHA)

    def test_failed_atomic_replace_preserves_previous_output_and_cleans_temp(self):
        self.output.parent.mkdir()
        self.output.write_bytes(b'keep previous candidate')
        with mock.patch.object(hatha.os, 'replace', side_effect=OSError('disk failure')):
            with self.assertRaises(OSError):
                hatha.main(['--write', '--output', str(self.output),
                            '--editorial-overlay', str(self.path)])
        self.assertEqual(self.output.read_bytes(), b'keep previous candidate')
        self.assertEqual(list(self.output.parent.iterdir()), [self.output])


if __name__ == '__main__':
    unittest.main()
