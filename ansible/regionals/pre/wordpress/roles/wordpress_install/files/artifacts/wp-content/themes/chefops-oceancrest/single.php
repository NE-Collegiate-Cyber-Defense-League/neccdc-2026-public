<?php get_header(); ?>
<main>
    <section class="hero" style="padding:80px 0 40px;">
        <div class="wrapper hero-grid">
            <div>
                <div class="eyebrow"><span></span><?php bloginfo('name'); ?></div>
                <h1><?php the_title(); ?></h1>
                <p class="lede">Published on <?php echo esc_html(get_the_date()); ?> by <?php the_author(); ?></p>
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
    <section>
        <div class="wrapper">
            <?php comments_template(); ?>
        </div>
    </section>
</main>
<?php get_footer(); ?>