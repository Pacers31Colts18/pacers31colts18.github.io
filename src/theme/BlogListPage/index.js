import React from 'react';
import Layout from '@theme/Layout';
import clsx from 'clsx';
import BlogListPaginator from '@theme/BlogListPaginator';
import BlogCard from '../BlogCard';
import styles from './styles.module.css';

export default function BlogListPage({ metadata, items }) {
  return (
    <Layout title={metadata.title}>
      <main className={clsx('container', styles.blogGrid)}>
        <h1 className={styles.pageTitle}>{metadata.title}</h1>

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

        <BlogListPaginator metadata={metadata} />
      </main>
    </Layout>
  );
}
