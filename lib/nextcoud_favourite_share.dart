import 'package:nextcloud/nextcloud.dart';

const _propNamespace = 'http://leonhardt.co.nz/ns';
const Map<String, String> _propNamespaces = {'$_propNamespace': 'le'};
const String _propOriginalId = 'le:original-id';

class NextCloudFavouriteShare {
  NextCloudFavouriteShare(this.client, this.sourceDir, this.targetDir) {
    // Register custom namespaces
    _propNamespaces
        .forEach((ns, prefix) => client.webDav.registerNamespace(ns, prefix));
  }

  /// The NextCloud client.
  final NextCloudClient client;

  /// Source folder.
  final String sourceDir;

  /// Shared folder.
  final String targetDir;

  List<WebDavFile> _sharedFiles;

  Future<int> syncFavorites() async {
    // Find all favourites in sourceDir
    final userFavorites = await client.webDav.filter(
        sourceDir, {'oc:favorite': '1'},
        props: {'oc:id', 'd:resourcetype'});

    // Find all shared files in targetDir
    _sharedFiles =
        await client.webDav.ls(targetDir, props: {'oc:id', _propOriginalId});

    // Process all favourites
    final processedFavorites = await Future.wait(
        userFavorites.map((favorite) => processFavorite(favorite)));

    // Couunt processed files
    final count = processedFavorites
        .map((updated) => updated ? 1 : 0)
        .reduce((previous, element) => previous + element);

    print('Synchronized favorites: $count of ${userFavorites.length}');
    return count;
  }

  Future<bool> processFavorite(WebDavFile favorite) async {
    print('Checking favorite: ${favorite.path} (${favorite.id})..');
    /*
    if (favorite.isDirectory) {
      print('>> Skipping ${favorite.name}: is a directory');
      return false;
    }
    */

    final alreadyShared = _sharedFiles
        .where((e) =>
            e.getOtherProp(_propOriginalId, _propNamespace) == favorite.id)
        .isNotEmpty;

    if (alreadyShared) {
      print('>> Skipping ${favorite.name}: already shared');
      return false;
    }

    // Share current favourite
    final target = '$targetDir/${favorite.name}';
    try {
      await client.webDav.copy(favorite.path, target);
    } on RequestException catch (ex) {
      if (ex.statusCode == 412) {
        // File exists already, update original ID.
      } else {
        // Some other problem.
        print('!> Failed to share ${favorite.name}: ${ex.statusCode}');
        return false;
      }
    }

    // Keep track of original ID
    final updated = await client.webDav.updateProps(
      target,
      {
        _propOriginalId: favorite.id,
      },
    );

    if (!updated) {
      print('!> Failed to set original ID on ${target}');
    }

    final sharedFile = await client.webDav.getProps(target, props: {
      'oc:id',
      _propOriginalId,
    });
    print(
        '+> Shared ${favorite.name}: to ${sharedFile.path} (${sharedFile.id})');
    return true;
  }
}
