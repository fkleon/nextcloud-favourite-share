import 'package:nextcloud/nextcloud.dart';
import 'package:nextcoud_favourite_share/nextcoud_favourite_share.dart';
import 'package:test/test.dart';

void main() {
  test('Constructor', () {
    final client = NextCloudClient('localhost', 'admin', 'admin');
    final sourceDir = '/files/admin/';
    final targetDir = '/files/admin/shared';
    final share = NextCloudFavouriteShare(client, sourceDir, targetDir);
    expect(share.client, isNotNull);
    expect(share.sourceDir, sourceDir);
    expect(share.targetDir, targetDir);
  });
}
