// Torrent content layout: Original
// Default Torrent Management Mode: Automatic
// Default Save Path: /media/downloads
// External program on finished: /scripts/xseed.sh "%F"

module.exports = {
  delay: 30,
  qbittorrentUrl: "http://localhost:80",

  torznab: [
    "http://prowlarr:9696/5/api?apikey={{ .PROWLARR_API_KEY }}", // td
    "http://prowlarr:9696/7/api?apikey={{ .PROWLARR_API_KEY }}", // ipt
  ],

  action: "inject",
  includeEpisodes: true,
  includeNonVideos: true,
  duplicateCategories: true,

  matchMode: "safe",
  skipRecheck: true,
  // linkType: "symlink",
  // linkDir: "/media/downloads/xseeds",

  // I have sonarr, radarr, and prowlarr categories set in qBittorrent
  // The save paths for them are set to the following:
  // dataDirs: [
  //   "/media/downloads/sonarr",
  //   "/media/downloads/radarr",
  //   "/media/downloads/prowlarr",
  //   "/media/downloads/torrents",
  // ],

  outputDir: "/downloads/complete/xseeds",
  torrentDir: "/config/qBittorrent/BT_backup",
};
