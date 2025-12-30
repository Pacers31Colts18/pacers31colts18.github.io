import React from 'react';
import clsx from 'clsx';
import styles from './styles.module.css';

export default function HomepageHeader() {
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <h1 className="hero__title">Joe Loveless</h1>
        <p className="hero__subtitle">Sr. Endpoint Configuration and Automation Engineer</p>
      </div>
    </header>
  );
}
