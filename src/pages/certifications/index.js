import React from 'react';
import Layout from '@theme/Layout';
import styles from './styles.module.css';
import { groups } from './_data';

export default function Certifications() {
  return (
    <Layout
      title="Certifications"
      description="Certifications page for Joe Loveless"
    >
      <main className={styles.container}>
        <h1 className={styles.pageTitle}>Certifications</h1>

        {groups.map((group) => (
          <section key={group.name} className={styles.group}>
            <h2 className={styles.groupTitle}>{group.name}</h2>
            <div className={styles.grid}>
              {group.certs.map((cert) => (
                <article key={cert.title} className={styles.card}>
                  <img src={cert.image} alt={cert.title} className={styles.badge} />
                  <h3 className={styles.certTitle}>{cert.title}</h3>
                  {(cert.issuer || cert.date) && (
                    <div className={styles.meta}>
                      {cert.issuer}
                      {cert.issuer && cert.date && <span className={styles.metaDot}>·</span>}
                      {cert.date}
                    </div>
                  )}
                  {cert.description && (
                    <p className={styles.description}>{cert.description}</p>
                  )}
                </article>
              ))}
            </div>
          </section>
        ))}
      </main>
    </Layout>
  );
}
