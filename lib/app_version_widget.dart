import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionWidget extends StatefulWidget {
  const AppVersionWidget({super.key});

  @override
  State<AppVersionWidget> createState() => _AppVersionWidgetState();
}

class _AppVersionWidgetState extends State<AppVersionWidget> {
  late final Future<PackageInfo> _packageInfo;

  @override
  void initState() {
    super.initState();
    _packageInfo = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _packageInfo,
      builder: (context, snapshot) {
        final packageInfo = snapshot.data;
        final versionText = packageInfo == null
            ? 'Akwarysta PRO'
            : 'Akwarysta PRO v${packageInfo.version} · build ${packageInfo.buildNumber}';

        return Center(
          child: Text(
            versionText,
            style: TextStyle(
              color: Colors.grey.shade700.withValues(alpha: 0.72),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        );
      },
    );
  }
}
