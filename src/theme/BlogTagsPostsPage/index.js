import React from 'react';
import Layout from '@theme/Layout';
import BlogCard from '../BlogCard';
import { normalizeTag } from '../utils/normalizeTag';
import styles from '../BlogListPage/styles.module.css';

export default function BlogTagsPostsPage({ tag, items }) {
  const normalized = normalizeTag(tag);

  return (
    <Layout title={`Posts tagged with "${normalized.label}"`}>
      <main className="container">
        <h1 className={styles.pageTitle}>
          {items.length} post{items.length !== 1 && 's'} tagged with "{normalized.label}"
        </h1>

        <div className={styles.grid}>
          {items.map((item) => {
            const content = item.content ?? item;
            return (
              <BlogCard
                key={content.metadata.permalink}
                fm={content.frontMatter}
                md={content.metadata}
              />
            );
          })}
        </div>
      </main>
    </Layout>
  );
}
