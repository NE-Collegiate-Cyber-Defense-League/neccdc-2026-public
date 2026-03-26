<?php
if (post_password_required()) {
    return;
}
?>

<div id="comments" class="comments-area panel" style="margin-top: 40px;">
    <?php if (have_comments()) : ?>
        <h3 class="comments-title">
            <?php
            $comment_count = get_comments_number();
            if ($comment_count === '1') {
                printf('One comment');
            } else {
                printf('%s comments', number_format_i18n($comment_count));
            }
            ?>
        </h3>

        <ol class="comment-list">
            <?php
            wp_list_comments(array(
                'style'      => 'ol',
                'short_ping' => true,
                'avatar_size' => 64,
                'callback'   => 'chefops_comment_callback'
            ));
            ?>
        </ol>

        <?php the_comments_navigation(); ?>

    <?php endif; ?>

    <?php if (!comments_open() && get_comments_number() && post_type_supports(get_post_type(), 'comments')) : ?>
        <p class="no-comments">Comments are closed.</p>
    <?php endif; ?>

    <?php
    comment_form(array(
        'title_reply' => 'Leave a Comment',
        'label_submit' => 'Post Comment',
        'comment_field' => '<p class="comment-form-comment"><label for="comment">Comment</label><textarea id="comment" name="comment" cols="45" rows="8" maxlength="65525" required="required"></textarea></p>',
        'fields' => array(
            'author' => '<p class="comment-form-author"><label for="author">Name <span class="required">*</span></label><input id="author" name="author" type="text" value="" size="30" maxlength="245" required="required"></p>',
            'email' => '<p class="comment-form-email"><label for="email">Email <span class="required">*</span></label><input id="email" name="email" type="email" value="" size="30" maxlength="100" required="required"></p>',
            'url' => '<p class="comment-form-url"><label for="url">Website</label><input id="url" name="url" type="url" value="" size="30" maxlength="200"></p>',
        ),
    ));
    ?>
</div>

<style>
.comments-area .comment-list {
    list-style: none;
    padding: 0;
}

.comments-area .comment {
    border-bottom: 1px solid var(--border);
    padding: 20px 0;
}

.comments-area .comment-author {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 8px;
}

.comments-area .avatar {
    border-radius: 50%;
}

.comments-area .fn {
    font-weight: 600;
    color: var(--aqua);
}

.comments-area .comment-meta {
    color: var(--slate);
    font-size: 0.9em;
}

.comments-area .comment-content {
    margin-top: 12px;
    line-height: 1.6;
}

.comment-form {
    margin-top: 40px;
}

.comment-form p {
    margin-bottom: 16px;
}

.comment-form label {
    display: block;
    margin-bottom: 4px;
    font-weight: 500;
}

.comment-form input,
.comment-form textarea {
    width: 100%;
    padding: 12px;
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    color: inherit;
    font-family: inherit;
}

.comment-form textarea {
    resize: vertical;
}

.comment-form .submit {
    background: linear-gradient(135deg, var(--aqua), var(--coral));
    color: var(--midnight);
    border: none;
    padding: 12px 24px;
    border-radius: var(--radius);
    font-weight: 600;
    cursor: pointer;
    transition: transform 0.2s;
}

.comment-form .submit:hover {
    transform: translateY(-2px);
}

.required {
    color: var(--coral);
}
</style>

<?php
function chefops_comment_callback($comment, $args, $depth) {
    $GLOBALS['comment'] = $comment;
    ?>
    <li <?php comment_class(); ?> id="comment-<?php comment_ID(); ?>">
        <article class="comment-body">
            <footer class="comment-meta">
                <div class="comment-author vcard">
                    <?php echo get_avatar($comment, 64, '', '', array('class' => 'avatar')); ?>
                    <b class="fn"><?php echo get_comment_author_link($comment); ?></b>
                    <span class="says">says:</span>
                </div>
                <div class="comment-metadata">
                    <time datetime="<?php comment_time('c'); ?>">
                        <?php printf('%1$s at %2$s', get_comment_date('', $comment), get_comment_time()); ?>
                    </time>
                    <?php edit_comment_link('Edit', ' <span class="edit-link">', '</span>'); ?>
                </div>
            </footer>
            <div class="comment-content">
                <?php comment_text(); ?>
            </div>
            <div class="reply">
                <?php comment_reply_link(array_merge($args, array('depth' => $depth, 'max_depth' => $args['max_depth']))); ?>
            </div>
        </article>
    <?php
}
?>