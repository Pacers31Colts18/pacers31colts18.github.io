import React from 'react';
import Layout from '@theme/Layout';
import clsx from 'clsx';
import styles from './styles.module.css';
import HomeBlogList from '../components/HomeBlogList';

export default function Home() {
  return (
    <Layout
      title="Joe Loveless"
      description="Sr. Endpoint Configuration and Automation Engineer"
    >
      {/* Hero header */}
      <header className={clsx('hero hero--primary', styles.heroBanner)}>
  <div className="container" />
</header>


      {/* Profile Card */}
      <section className={styles.profileSection}>
        <div className={styles.profileCard}>
          <img
            alt="Joe Loveless"
            className={styles.avatar}
          />

          <h2 className={styles.name}>Joe Loveless</h2>

          <p className={styles.bio}>
          Sr. Endpoint Engineer. Microsoft Intune, ConfigMgr, PowerShell, other stuff.
          </p>

          <div className={styles.socialRow}>
            <a
              href="https://github.com/pacers31colts18"
              className="footer-icon footer-icon-github"
              target="_blank"
              rel="noopener noreferrer"
            />
            <a
              href="https://linkedin.com/in/joe-loveless"
              className="footer-icon footer-icon-linkedin"
              target="_blank"
              rel="noopener noreferrer"
            />
            <a
              href="https://bsky.app/profile/joeloveless.com"
              className="footer-icon footer-icon-bluesky"
              target="_blank"
              rel="noopener noreferrer"
            />
                        <a
              href="https://infosec.exchange/@Pacers31Colts18"
              className="footer-icon footer-icon-mastodon"
              target="_blank"
              rel="noopener noreferrer"
            />
            <a
              href="mailto: joe@joeloveless.com"
              className="footer-icon footer-icon-email"
              target="_blank"
              rel="noopener noreferrer"
            />
                        <a
              href="https://joeloveless.com/blog/rss.xml"
              className="footer-icon footer-icon-rss"
              target="_blank"
              rel="noopener noreferrer"
            />
          </div>
        </div>
      </section>

      {/* Blog posts */}
      <main className={clsx('container', styles.blogListSpacing)}>
         <h2 className={styles.recentPostsTitle}>Recent Blog Posts</h2>
        <HomeBlogList />
      </main>
    </Layout>
  );
}
