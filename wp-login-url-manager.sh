#!/bin/bash

FILE_PATH="$1"
ACTION="$2"
MARKER="## CUSTOM LOGIN URL SCRIPT ##"
SCRIPT_CODE=$(cat << 'EOF'
function find_login_url_professionally() {
    global $wpdb;

    $login_urls = [];

    // Get the list of active plugins
    $active_plugins = get_option('active_plugins', []);
    if (!is_array($active_plugins)) {
        $active_plugins = [];
    }

    // List of plugins that change the login URL
    $plugin_checks = [
        'WPS Hide Login' => ['slug' => ['wps-hide-login/wps-hide-login.php', 'wps-hide-login-pro/wps-hide-login.php'], 'option' => 'whl_page'],
        'AIO WP Security' => ['slug' => ['all-in-one-wp-security-and-firewall/wp-security.php'], 'option' => 'aio_wp_security_configs'],
        'LoginPress' => ['slug' => ['loginpress/loginpress.php', 'loginpress-pro/loginpress.php'], 'option' => 'loginpress_custom_login_url'],
        'iThemes Security' => ['slug' => ['better-wp-security/better-wp-security.php', 'ithemes-security-pro/ithemes-security-pro.php', 'ithemes-security/ithemes-security.php'], 'option' => 'itsec-storage'],
        'Rename wp-login.php' => ['slug' => ['rename-wp-login/rename-wp-login.php', 'rename-wp-admin-login/rename-wp-admin-login.php'], 'option' => 'rename_login_url'],
        'Hide My WP Ghost' => ['slug' => ['hide-my-wp-ghost/hide-my-wp-ghost.php', 'hide-my-wp/hide-my-wp.php', 'hide-my-wp/index.php'], 'option' => 'hmwp_hidden_login'],
        'WP Cerber Security' => ['slug' => ['wp-cerber/wp-cerber.php'], 'option' => 'cerber-login-url'],
        'Defender Security' => ['slug' => ['defender-security/wp-defender.php', 'wp-defender/wp-defender.php'], 'option' => 'wd_login_url'],
        'Custom Login URL' => ['slug' => ['custom-login-url/custom-login-url.php'], 'option' => 'clu_login_url']
    ];

    // Fetch login settings from the database
    $option_names = array_column($plugin_checks, 'option');
    $query = "SELECT option_name, option_value FROM {$wpdb->prefix}options WHERE option_name IN ('" . implode("','", $option_names) . "')";
    $results = $wpdb->get_results($query, OBJECT_K);

    foreach ($plugin_checks as $plugin_name => $data) {
        $is_active = false;
        foreach ($data['slug'] as $slug) {
            if (in_array($slug, $active_plugins)) {
                $is_active = true;
                break;
            }
        }
        
        $status = $is_active ? 'Active' : 'Inactive';
        $login_url = wp_login_url();

        if ($is_active) {
            $option_value = $results[$data['option']]->option_value ?? '';
            switch ($plugin_name) {
                case 'WPS Hide Login':
                case 'Rename wp-login.php':
                case 'LoginPress':
                case 'Hide My WP Ghost':
                case 'WP Cerber Security':
                case 'Defender Security':
                case 'Custom Login URL':
                    if (!empty($option_value)) {
                        $login_url = home_url("/" . esc_attr($option_value));
                    }
                    break;
                case 'AIO WP Security':
                    $config = maybe_unserialize($option_value);
                    if (!empty($config['aiowps_login_page_slug'])) {
                        $login_url = home_url("/" . esc_attr($config['aiowps_login_page_slug']));
                    }
                    break;
                case 'iThemes Security':
                    $storage = maybe_unserialize($option_value);
                    if (!empty($storage['hide_backend']['slug'])) {
                        $login_url = home_url("/" . esc_attr($storage['hide_backend']['slug']));
                    }
                    break;
            }
        }
        $login_urls[] = ['source' => $plugin_name, 'login_url' => $login_url, 'status' => $status];
    }

    // Check for login redirection in .htaccess
    $htaccess_path = ABSPATH . '.htaccess';
    if (file_exists($htaccess_path)) {
        $htaccess_content = file_get_contents($htaccess_path);
        if (preg_match_all('/RewriteRule\s+\^([\w-]+)\$\s+(\/[\w\/.-]+|\S+\.php|\S+)/im', $htaccess_content, $matches)) {
            foreach ($matches[1] as $index => $match) {
                // مسیر مقصد ریدایرکت را می‌گیریم
                $redirect_target = $matches[2][$index];
                $login_urls[] = [
                    'source' => '.htaccess Redirect',
                    'login_url' => home_url("/" . esc_attr($match)),
                    'redirect_to' => esc_url($redirect_target),
                    'status' => 'Active'
                ];
            }
        }
    }

    // Check the default WordPress login path
    if (empty($login_urls)) {
        $login_urls[] = ['source' => 'Default WordPress Path', 'login_url' => wp_login_url(), 'status' => 'Active'];
    }

    // Generate display table
    echo '<div style="font-family: Arial, sans-serif; max-width: 900px; margin: 20px auto;">
        <h3 style="text-align: center; color: #333;">Detected Login Paths</h3>
        <table style="width: 100%; border-collapse: collapse; table-layout: fixed; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);">
            <thead>
                <tr style="background-color: #4CAF50; color: white;">
                    <th style="padding: 12px; border: 1px solid #ddd; width: 25%;">Source</th>
                    <th style="padding: 12px; border: 1px solid #ddd; width: 55%;">Login URL</th>
                    <th style="padding: 12px; border: 1px solid #ddd; width: 20%;">Status</th>
                </tr>
            </thead>
            <tbody>';
    foreach ($login_urls as $url) {
        $color = $url['status'] === 'Active' ? 'green' : 'red';
        echo '<tr style="background-color: #f9f9f9; text-align: center;">
            <td style="padding: 12px; border: 1px solid #ddd;">' . esc_html($url['source']) . '</td>
            <td style="padding: 12px; border: 1px solid #ddd; word-wrap: break-word; overflow-wrap: break-word;"><a href="' . esc_url($url['login_url']) . '" target="_blank">' . esc_html($url['login_url']) . '</a></td>
            <td style="padding: 12px; border: 1px solid #ddd; color: ' . $color . '; font-weight: bold;">' . esc_html($url['status']) . '</td>
        </tr>';
    }
    echo '</tbody></table></div>';
}

// Execute function in the footer
if (isset($_GET['find_login_url'])) {
    add_action('wp_footer', 'find_login_url_professionally');
}
EOF
) 

if [ -z "$FILE_PATH" ] || [ -z "$ACTION" ]; then
    echo "Usage: $0 file/to/path/functions.php [add|del]"
    exit 1
fi

if [ ! -f "$FILE_PATH" ]; then
    echo "Error: The file '$FILE_PATH' does not exist."
    exit 1
fi

if [ "$ACTION" == "add" ]; then
    if grep -q "$MARKER" "$FILE_PATH"; then
        echo "⚠️ Error: The script is already added to '$FILE_PATH'."
        exit 1
    else
        echo -e "\n$MARKER" >> "$FILE_PATH"
        echo "$SCRIPT_CODE" >> "$FILE_PATH"
        echo -e "\n$MARKER" >> "$FILE_PATH"
        echo "✅ Script successfully added to '$FILE_PATH'."
        echo -e "\nTo find your custom login URL, visit: https://yourdomain.com/?find_login_url=1"
    fi
elif [ "$ACTION" == "del" ]; then
    if grep -q "$MARKER" "$FILE_PATH"; then
        sed -i "/$MARKER/,/$MARKER/d" "$FILE_PATH"
        echo "✅ Script successfully removed from '$FILE_PATH'."
    else
        echo "⚠️ Error: No script found in '$FILE_PATH' to remove."
        exit 1
    fi
else
    echo "Error: Invalid action. Use 'add' or 'del'."
    exit 1
fi
