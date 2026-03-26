<?php get_header(); ?>
<main>
    <section class="hero" style="padding:80px 0 50px;">
        <div class="wrapper hero-grid">
            <div>
                <div class="eyebrow"><span></span>ChefOps Updates</div>
                <h1>Latest notes from the operations floor.</h1>
                <p class="lede">Weekly briefings, change retrospectives, and incident learnings that keep Ocean Crest Kitchens aligned.</p>
            </div>
        </div>
    </section>

    <section>
        <div class="wrapper" id="sneeit-content-container">
            <?php if (have_posts()) : ?>
                <div class="service-grid">
                    <?php while (have_posts()) : the_post(); ?>
                        <article id="post-<?php the_ID(); ?>" <?php post_class('panel'); ?>>
                            <span class="badge"><?php echo esc_html(get_the_date()); ?></span>
                            <h3><a href="<?php the_permalink(); ?>"><?php the_title(); ?></a></h3>
                            <p class="muted"><?php echo esc_html(wp_trim_words(get_the_excerpt(), 26)); ?></p>
                            <a class="ghost" href="<?php the_permalink(); ?>">Read more</a>
                        </article>
                    <?php endwhile; ?>
                </div>
                <div id="sneeit-pagination-container" class="wrapper" style="margin-top:20px;">
                    <?php the_posts_pagination(); ?>
                </div>
            <?php else : ?>
                <div class="panel">
                    <h3>No updates yet</h3>
                    <p class="muted">Come back soon for change logs, runbooks, and status recaps.</p>
                </div>
            <?php endif; ?>
        </div>
    </section>
</main>
<?php
if (function_exists('sneeit_articles_pagination')) {
    sneeit_articles_pagination(array(
        'ajax_handler' => 'sneeit_articles_pagination',
        'pagination_container' => '#sneeit-pagination-container',
        'content_container' => '#sneeit-content-container'
    ));
}
?>
<?php get_footer(); ?>
