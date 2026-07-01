import React from 'react';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';
import clsx from 'clsx';
import BlogCard from '../BlogCard';
import styles from './styles.module.css';

export default function BlogListPage({ metadata, items }) {
  const { previousPage, nextPage, page, totalPages } = metadata;

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

        {(previousPage || nextPage) && (
          <div className={styles.pagination}>
            {previousPage ? (
              <Link to={previousPage} className={styles.pageBtn}>← prev</Link>
            ) : (
              <span className={clsx(styles.pageBtn, styles.pageBtnDisabled)}>← prev</span>
            )}
            <span className={styles.pageInfo}>{page} / {totalPages}</span>
            {nextPage ? (
              <Link to={nextPage} className={styles.pageBtn}>next →</Link>
            ) : (
              <span className={clsx(styles.pageBtn, styles.pageBtnDisabled)}>next →</span>
            )}
          </div>
        )}
      </main>
    </Layout>
  );
}
