<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
<header class="site-header">
    <div class="wrapper nav">
        <a class="brand" href="<?php echo esc_url(home_url('/')); ?>">
            <span class="brand-mark">CO</span>
            <div>
                <div>ChefOps</div>
                <small style="color:#9fb0cd;">Operations for Ocean Crest Kitchens</small>
            </div>
        </a>
        <?php
        wp_nav_menu(
            array(
                'theme_location' => 'primary',
                'menu_class'     => 'nav-links',
                'container'      => false,
                'fallback_cb'    => 'chefops_oceancrest_fallback_menu',
                'depth'          => 1,
            )
        );
        ?>
    </div>
</header>
