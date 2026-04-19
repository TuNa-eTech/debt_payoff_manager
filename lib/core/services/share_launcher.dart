import 'package:share_plus/share_plus.dart';

import '../models/data_export_artifact.dart';

abstract class ShareLauncher {
  Future<void> shareArtifact(DataExportArtifact artifact);
}

class SharePlusLauncher implements ShareLauncher {
  @override
  Future<void> shareArtifact(DataExportArtifact artifact) async {
    await Share.shareXFiles(
      [
        XFile(
          artifact.path,
          mimeType: artifact.mimeType,
          name: artifact.fileName,
        ),
      ],
      subject: _subjectFor(artifact.kind),
      text: _textFor(artifact.kind),
    );
  }

  String _subjectFor(DataExportArtifactKind kind) {
    switch (kind) {
      case DataExportArtifactKind.csvBundle:
        return 'Debt Payoff Manager CSV Export';
      case DataExportArtifactKind.localBackup:
        return 'Debt Payoff Manager Local Backup';
    }
  }

  String _textFor(DataExportArtifactKind kind) {
    switch (kind) {
      case DataExportArtifactKind.csvBundle:
        return 'Full CSV export generated from Debt Payoff Manager.';
      case DataExportArtifactKind.localBackup:
        return 'Local backup bundle generated from Debt Payoff Manager.';
    }
  }
}
