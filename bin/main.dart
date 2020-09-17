import 'dart:io';

import 'package:nextcoud_favourite_share/nextcoud_favourite_share.dart'
    show NextCloudFavouriteShare;

import 'package:args/args.dart';
import 'package:nextcloud/nextcloud.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('host',
        defaultsTo: 'http://localhost:8081',
        help: 'The NextCloud host to connect to')
    ..addOption('username',
        defaultsTo: 'admin', help: 'The username to connect with')
    ..addOption('password', defaultsTo: 'admin', help: 'The password to use')
    ..addOption('source-dir',
        help: 'WebDAV path of the directory to scan for favourites',
        valueHelp: '/files/admin/')
    ..addOption('target-dir',
        help: 'WebDAV path of the directory to copy favorites to',
        valueHelp: '/files/admin/shared');

  var args;
  try {
    args = parser.parse(arguments);
  } catch (ex) {
    print('Available options:');
    print(parser.usage);
    exit(1);
  }

  final host = args['host'];
  final username = args['username'];
  final password = args['password'];
  final sourceFolder = args['source-dir'] ?? '/files/$username/';
  final sharedFolder = args['target-dir'] ?? '/files/$username/shared';

  final nfs = NextCloudFavouriteShare(
      NextCloudClient(host, username, password), sourceFolder, sharedFolder);

  await nfs.syncFavorites();
  print('Synchronized favorites for user $username.');
}
