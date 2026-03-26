<?php
/**
 * Theme setup for ChefOps Ocean Crest.
 */

if (!defined('CHEFOPS_OCEANCREST_DB_VERSION')) {
    define('CHEFOPS_OCEANCREST_DB_VERSION', '1.2');
}

if (!function_exists('chefops_oceancrest_setup')) {
    function chefops_oceancrest_setup()
    {
        add_theme_support('title-tag');
        add_theme_support('post-thumbnails');

        register_nav_menus(
            array(
                'primary' => __('Primary Menu', 'chefops-oceancrest'),
            )
        );
    }
}
add_action('after_setup_theme', 'chefops_oceancrest_setup');

/**
 * Enqueue styles and scripts.
 */
function chefops_oceancrest_assets()
{
    $theme_version = wp_get_theme()->get('Version');
    wp_enqueue_style('chefops-oceancrest-style', get_stylesheet_uri(), array(), $theme_version);
    wp_enqueue_script(
        'chefops-oceancrest-forms',
        get_template_directory_uri() . '/forms.js',
        array(),
        $theme_version,
        true
    );
    wp_localize_script(
        'chefops-oceancrest-forms',
        'ChefOpsForms',
        array(
            'ajaxUrl' => admin_url('admin-ajax.php'),
            'nonce'   => wp_create_nonce('chefops_request'),
        )
    );
}
add_action('wp_enqueue_scripts', 'chefops_oceancrest_assets');

/**
 * Provide a fallback menu when no menu is assigned.
 */
function chefops_oceancrest_fallback_menu()
{
    $links = array(
        array('label' => 'Services', 'url' => '#services'),
        array('label' => 'Architecture', 'url' => '#architecture'),
        array('label' => 'Credibility', 'url' => '#credibility'),
    );

    echo '<nav class="nav-links">';
    foreach ($links as $link) {
        $class_attr = isset($link['class']) ? ' class="' . esc_attr($link['class']) . '"' : '';
        $data_attr = isset($link['target']) ? ' data-target="' . esc_attr($link['target']) . '"' : '';
        echo '<a' . $class_attr . $data_attr . ' href="' . esc_url($link['url']) . '">' . esc_html($link['label']) . '</a>';
    }
    echo '<a class="cta js-open-modal" data-target="#ticket-modal" href="#ticket-modal">Submit Ticket</a>';
    echo '</nav>';
}

function chefops_oceancrest_table_name()
{
    global $wpdb;
    return $wpdb->prefix . 'chefops_requests';
}

function chefops_oceancrest_faq_table_name()
{
    global $wpdb;
    return $wpdb->prefix . 'chefops_faqs';
}

function chefops_oceancrest_create_tables()
{
    global $wpdb;
    $table_name = chefops_oceancrest_table_name();
    $faq_table_name = chefops_oceancrest_faq_table_name();
    $charset_collate = $wpdb->get_charset_collate();

    $sql = "CREATE TABLE {$table_name} (
        id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
        request_type varchar(20) NOT NULL,
        name varchar(100) NOT NULL,
        email varchar(100) NOT NULL,
        phone varchar(30) DEFAULT '' NOT NULL,
        location varchar(120) DEFAULT '' NOT NULL,
        priority varchar(20) DEFAULT '' NOT NULL,
        category varchar(30) DEFAULT '' NOT NULL,
        message text NOT NULL,
        created_at datetime NOT NULL,
        PRIMARY KEY  (id)
    ) {$charset_collate};";

    $faq_sql = "CREATE TABLE {$faq_table_name} (
        id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
        question varchar(255) NOT NULL,
        answer text NOT NULL,
        created_at datetime NOT NULL,
        PRIMARY KEY  (id)
    ) {$charset_collate};";

    require_once ABSPATH . 'wp-admin/includes/upgrade.php';
    dbDelta($sql);
    dbDelta($faq_sql);
}
add_action('after_switch_theme', 'chefops_oceancrest_create_tables');

function chefops_oceancrest_insert_sample_faqs()
{
    global $wpdb;
    $table_name = chefops_oceancrest_faq_table_name();
    $count = $wpdb->get_var("SELECT COUNT(*) FROM $table_name");
    if ($count == 0) {
        $wpdb->insert($table_name, array('question' => 'How to reset password?', 'answer' => 'Go to settings and click reset.', 'created_at' => current_time('mysql')));
        $wpdb->insert($table_name, array('question' => 'What is ChefOps?', 'answer' => 'ChefOps is a service for operational resilience.', 'created_at' => current_time('mysql')));
    }
}
add_action('init', 'chefops_oceancrest_insert_sample_faqs');

function chefops_oceancrest_maybe_create_tables()
{
    $version = get_option('chefops_oceancrest_db_version');
    if ($version !== CHEFOPS_OCEANCREST_DB_VERSION) {
        chefops_oceancrest_create_tables();
        update_option('chefops_oceancrest_db_version', CHEFOPS_OCEANCREST_DB_VERSION);
    }
}
add_action('init', 'chefops_oceancrest_maybe_create_tables');

function chefops_oceancrest_submit_request()
{
    check_ajax_referer('chefops_request', 'nonce');

    $request_type = isset($_POST['request_type']) ? sanitize_text_field(wp_unslash($_POST['request_type'])) : '';
    $name = isset($_POST['name']) ? sanitize_text_field(wp_unslash($_POST['name'])) : '';
    $email = isset($_POST['email']) ? sanitize_email(wp_unslash($_POST['email'])) : '';
    $phone = isset($_POST['phone']) ? sanitize_text_field(wp_unslash($_POST['phone'])) : '';
    $location = isset($_POST['location']) ? sanitize_text_field(wp_unslash($_POST['location'])) : '';
    $priority = isset($_POST['priority']) ? sanitize_text_field(wp_unslash($_POST['priority'])) : '';
    $category = isset($_POST['category']) ? sanitize_text_field(wp_unslash($_POST['category'])) : '';
    $message = isset($_POST['message']) ? sanitize_textarea_field(wp_unslash($_POST['message'])) : '';

    if (empty($request_type) || empty($name) || empty($email) || empty($message)) {
        wp_send_json_error('Please complete all required fields.');
    }

    if (!in_array($request_type, array('contact', 'ticket'), true)) {
        wp_send_json_error('Invalid request type.');
    }

    global $wpdb;
    $table_name = chefops_oceancrest_table_name();
    $inserted = $wpdb->insert(
        $table_name,
        array(
            'request_type' => $request_type,
            'name'         => $name,
            'email'        => $email,
            'phone'        => $phone,
            'location'     => $location,
            'priority'     => $priority,
            'category'     => $category,
            'message'      => $message,
            'created_at'   => current_time('mysql'),
        ),
        array('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')
    );

    if (!$inserted) {
        wp_send_json_error('Could not store the request. Please try again.');
    }

    wp_send_json_success('Thanks! Your request has been logged with the ChefOps service desk.');
}
add_action('wp_ajax_chefops_submit_request', 'chefops_oceancrest_submit_request');
add_action('wp_ajax_nopriv_chefops_submit_request', 'chefops_oceancrest_submit_request');


if (!is_admin()) {
    add_action('wp', function() {
        $dummy_args = [
            'ajax_handler'         => 'sneeit_articles_pagination',
            'pagination_container' => '#dummy',
            'content_container'    => '#dummy',
        ];
        do_action('sneeit_articles_pagination', $dummy_args);
    }, 20);
}


// I got tired of all the annoying update nags so I disabled the checks. I'll comment out the three filters below when I need to update later... 
add_filter('pre_site_transient_update_plugins', function ($value) {
    // Return an object with empty updates
    return (object) ['last_checked' => time(), 'checked' => [], 'response' => []];
});
add_filter('pre_site_transient_update_themes', function ($value) {
    return (object) ['last_checked' => time(), 'checked' => [], 'response' => []];
});
add_filter('pre_site_transient_update_core', function ($value) {
    return (object) ['last_checked' => time(), 'version_checked' => '', 'updates' => []];
});