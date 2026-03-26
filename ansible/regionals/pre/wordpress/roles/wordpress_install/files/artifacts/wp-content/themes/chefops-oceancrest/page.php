<?php get_header(); ?>
<main>
    <section class="hero" style="padding:80px 0 40px;">
        <div class="wrapper hero-grid">
            <div>
                <div class="eyebrow"><span></span><?php bloginfo('name'); ?></div>
                <h1><?php the_title(); ?></h1>
                <?php if (has_excerpt()) : ?>
                    <p class="lede"><?php echo esc_html(get_the_excerpt()); ?></p>
                <?php endif; ?>
            </div>
        </div>
    </section>
    <section>
        <div class="wrapper">
            <div class="panel">
                <?php
                while (have_posts()) :
                    the_post();
                    the_content();
                endwhile;
                ?>
            </div>
        </div>
    </section>
</main>
<?php get_footer(); ?>
