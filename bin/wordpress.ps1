$wordpress = Invoke-RestMethod -Uri 'https://api.wordpress.org/core/version-check/1.7/'
Invoke-WebRequest -OutFile '/tmp/wordpress.zip' $wordpress.offers[0].download
Expand-Archive -DestinationPath '.' -Path '/tmp/wordpress.zip'

Set-Location -Path 'wordpress'

Set-Content -Path '.htaccess' -Value @'
RewriteEngine On
RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
'@
Set-Content -Path 'wp-config.php' -Value @'
<?php
if ( $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https' ) {
  $_SERVER['HTTPS'] = 'on';
}
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}
define( 'DB_DIR', ABSPATH . 'wp-content/contents/databases/' );
define( 'DB_FILE', '.ht.sqlite' );
$table_prefix = 'wp_';
// Generate these keys and salts from https://api.wordpress.org/secret-key/1.1/salt/
define( 'AUTH_KEY',         getenv( 'AUTH_KEY' ) );
define( 'SECURE_AUTH_KEY',  getenv( 'SECURE_AUTH_KEY' ) );
define( 'LOGGED_IN_KEY',    getenv( 'LOGGED_IN_KEY' ) );
define( 'NONCE_KEY',        getenv( 'NONCE_KEY' ) );
define( 'AUTH_SALT',        getenv( 'AUTH_SALT' ) );
define( 'SECURE_AUTH_SALT', getenv( 'SECURE_AUTH_SALT' ) );
define( 'LOGGED_IN_SALT',   getenv( 'LOGGED_IN_SALT' ) );
define( 'NONCE_SALT',       getenv( 'NONCE_SALT' ) );
define( 'AUTOMATIC_UPDATER_DISABLED', true );
define( 'DISABLE_WP_CRON', true );
define( 'WP_DEBUG', false );
define( 'DISALLOW_FILE_EDIT', true );
define( 'DISALLOW_FILE_MODS', true );
define( 'WP_POST_REVISIONS', false );
define( 'UPLOADS', 'wp-content/contents/uploads' );
require_once ABSPATH . 'wp-settings.php';
'@

Set-Location -Path 'wp-content'

$wordpressSqlite = Invoke-RestMethod -Uri 'https://api.github.com/repos/aaemnnosttv/wp-sqlite-db'
Invoke-WebRequest -OutFile 'db.php' -Uri "https://raw.githubusercontent.com/aaemnnosttv/wp-sqlite-db/$($wordpressSqlite.default_branch)/src/db.php"

Set-Location -Path 'themes'

foreach ($t in $wordpressExtensions.themes.Split(' ')) {
    $theme = Invoke-RestMethod -ErrorAction 'SilentlyContinue' -Uri "https://api.wordpress.org/themes/info/1.1/?action=theme_information&request[slug]=$($t)"
    Invoke-WebRequest -ErrorAction 'SilentlyContinue' -OutFile "/tmp/theme-$($t).zip" -Uri $theme.download_link
    Expand-Archive -ErrorAction 'SilentlyContinue' -DestinationPath '.' -Path "/tmp/theme-$($t).zip"
}

Set-Location -Path '..'

Set-Location -Path 'plugins'

foreach ($p in $wordpressExtensions.plugins.Split(' ')) {
    $plugin = Invoke-RestMethod -ErrorAction 'SilentlyContinue' -Uri "https://api.wordpress.org/plugins/info/1.0/$($p).json"
    Invoke-WebRequest -ErrorAction 'SilentlyContinue' -OutFile "/tmp/plugin-$($p).zip" -Uri $($plugin.versions.PSObject.Properties | Select-Object -Last 1 -Skip 1).Value
    Expand-Archive -ErrorAction 'SilentlyContinue' -DestinationPath '.' -Path "/tmp/plugin-$($p).zip"
}

Set-Location -Path '..'
