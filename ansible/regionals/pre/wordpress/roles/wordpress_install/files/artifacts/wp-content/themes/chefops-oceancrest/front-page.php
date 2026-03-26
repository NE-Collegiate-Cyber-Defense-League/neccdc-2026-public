<?php get_header(); ?>

<style>
/* Critical above-the-fold CSS – inline for instant paint */
.hero-critical {
  position: relative;
  overflow: hidden;
  padding: 140px 0 100px;
  background: radial-gradient(circle at 10% 20%, rgba(65, 214, 195, 0.12), transparent 30%),
    radial-gradient(circle at 90% 10%, rgba(251, 117, 66, 0.15), transparent 25%),
    linear-gradient(180deg, rgba(11, 16, 33, 0.95), #060914);
}

.hero-critical::before,
.hero-critical::after {
  content: "";
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.hero-critical::before {
  background: radial-gradient(circle at 20% 20%, rgba(65, 214, 195, 0.16), transparent 35%),
    radial-gradient(circle at 80% 10%, rgba(251, 117, 66, 0.22), transparent 40%);
  opacity: 0.75;
}

.hero-critical::after {
  background: linear-gradient(140deg, rgba(255, 255, 255, 0.08), transparent 50%),
    linear-gradient(230deg, rgba(4, 9, 26, 0.7), transparent 40%);
  mix-blend-mode: screen;
}

.hero-content {
  position: relative;
  z-index: 2;
  max-width: 720px;
  margin: 0 auto;
  text-align: center;
}

.hero-eyebrow {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 40px;
  padding: 10px 16px;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  font-weight: 700;
  color: #f4f7ff;
  font-size: 12px;
  margin-bottom: 20px;
  animation: fadeInDown 0.8s ease-out;
}

.hero-eyebrow::before {
  content: "";
  display: inline-block;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: linear-gradient(135deg, #41d6c3, #fb7542);
  box-shadow: 0 0 18px rgba(65, 214, 195, 0.8);
  margin-right: 6px;
}

.hero-critical h1 {
  margin: 0 0 20px;
  font-family: "Space Grotesk", "Manrope", system-ui, sans-serif;
  font-size: clamp(36px, 7vw, 68px);
  line-height: 1.08;
  color: #fff;
  font-weight: 700;
  letter-spacing: -0.02em;
  animation: fadeInUp 0.9s ease-out 0.1s both;
}

.hero-critical .hero-tagline {
  font-size: 20px;
  color: #c8d5ed;
  line-height: 1.6;
  max-width: 600px;
  margin: 0 auto 32px;
  animation: fadeInUp 0.9s ease-out 0.2s both;
}

.hero-ctas {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 14px;
  animation: fadeInUp 0.9s ease-out 0.3s both;
}

@keyframes fadeInDown {
  from { opacity: 0; transform: translateY(-20px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Services showcase styling */
.services-showcase {
  position: relative;
  padding: 100px 0;
  background: linear-gradient(180deg, #060914 0%, rgba(11, 16, 33, 0.6) 100%);
}

.services-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 24px;
  margin-top: 48px;
}

.service-card {
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 16px;
  padding: 32px;
  backdrop-filter: blur(6px);
  transition: all 0.3s ease;
  display: flex;
  flex-direction: column;
}

.service-card:hover {
  background: rgba(255, 255, 255, 0.08);
  border-color: rgba(65, 214, 195, 0.5);
  transform: translateY(-4px);
  box-shadow: 0 20px 40px rgba(65, 214, 195, 0.1);
}

.service-icon {
  width: 56px;
  height: 56px;
  margin-bottom: 20px;
  color: #41d6c3;
  opacity: 0.9;
}

.service-icon svg {
  width: 100%;
  height: 100%;
}

.service-card h3 {
  margin: 0 0 12px;
  font-size: 22px;
  color: #fff;
  font-family: "Space Grotesk", "Manrope", system-ui, sans-serif;
}

.service-card p {
  color: #c8d5ed;
  line-height: 1.6;
  margin: 0 0 20px;
  flex-grow: 1;
}

.service-features {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.service-features li {
  color: #9fb0cd;
  font-size: 14px;
  padding-left: 20px;
  position: relative;
}

.service-features li::before {
  content: "✓";
  position: absolute;
  left: 0;
  color: #41d6c3;
  font-weight: bold;
}

/* Architecture Section */
.architecture-section {
  padding: 100px 0;
}

.architecture-diagram {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20px;
  margin: 60px 0;
  flex-wrap: wrap;
  min-height: 200px;
}

.architecture-entity {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.06);
  border: 2px solid rgba(255, 255, 255, 0.12);
  border-radius: 16px;
  padding: 40px 32px;
  min-width: 160px;
  text-align: center;
  position: relative;
  transition: all 0.3s ease;
}

.architecture-entity.chefops {
  background: linear-gradient(135deg, rgba(65, 214, 195, 0.15), rgba(251, 117, 66, 0.15));
  border: 2px solid rgba(65, 214, 195, 0.4);
  box-shadow: 0 0 40px rgba(65, 214, 195, 0.2);
}

.entity-icon {
  font-size: 48px;
  margin-bottom: 12px;
}

.entity-label {
  font-family: "Space Grotesk", "Manrope", system-ui, sans-serif;
  font-size: 18px;
  font-weight: 700;
  color: #fff;
}

.entity-sublabel {
  font-size: 12px;
  color: #9fb0cd;
  margin-top: 8px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.architecture-connector {
  font-size: 24px;
  color: #41d6c3;
  flex-shrink: 0;
}

.architecture-text {
  text-align: center;
  color: #c8d5ed;
  line-height: 1.8;
  max-width: 680px;
  margin: 0 auto;
  font-size: 16px;
}

/* Credibility Section */
.credibility-section {
  padding: 100px 0;
  background: linear-gradient(180deg, #060914 0%, rgba(11, 16, 33, 0.6) 100%);
}

.credibility-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 32px;
  margin-top: 60px;
}

.credibility-item {
  text-align: center;
}

.credibility-metric {
  font-family: "Space Grotesk", "Manrope", system-ui, sans-serif;
  font-size: 48px;
  font-weight: 800;
  color: #41d6c3;
  margin-bottom: 8px;
}

.credibility-label {
  color: #c8d5ed;
  font-size: 16px;
  line-height: 1.5;
}

/* Value props as cards */
.value-props {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 20px;
  margin-top: 48px;
}

.value-prop {
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 12px;
  padding: 24px;
  backdrop-filter: blur(6px);
}

.value-prop h4 {
  margin: 0 0 12px;
  color: #fff;
  font-family: "Space Grotesk", "Manrope", system-ui, sans-serif;
}

.value-prop p {
  margin: 0;
  color: #9fb0cd;
  font-size: 14px;
  line-height: 1.6;
}

/* Call-to-action section */
.cta-section {
  padding: 80px 0;
  text-align: center;
}

.cta-section h2 {
  margin-bottom: 20px;
}

.cta-section p {
  color: #c8d5ed;
  margin-bottom: 32px;
  font-size: 18px;
}

/* Modal styles */
.modal {
  display: none;
  position: fixed;
  inset: 0;
  z-index: 9999;
  align-items: center;
  justify-content: center;
}

.modal.is-active {
  display: flex;
}

.modal-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(4px);
}

.modal-content {
  position: relative;
  z-index: 10000;
  background: linear-gradient(135deg, rgba(15, 23, 42, 0.98), rgba(11, 16, 33, 0.98));
  border: 1px solid rgba(65, 214, 195, 0.2);
  border-radius: 16px;
  padding: 40px;
  max-width: 500px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
}

.modal-close {
  position: absolute;
  top: 16px;
  right: 16px;
  background: none;
  border: none;
  font-size: 28px;
  color: #9fb0cd;
  cursor: pointer;
  transition: color 0.2s;
}

.modal-close:hover {
  color: #41d6c3;
}

.modal-content h2 {
  margin: 0 0 24px;
  color: #fff;
  font-family: "Space Grotesk", "Manrope", system-ui, sans-serif;
  font-size: 28px;
}

.form-group {
  margin-bottom: 20px;
  display: flex;
  flex-direction: column;
}

.form-group label {
  color: #c8d5ed;
  margin-bottom: 8px;
  font-weight: 500;
}

.form-group input,
.form-group textarea,
.form-group select {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 8px;
  padding: 12px 16px;
  color: #fff;
  font-family: "Manrope", system-ui, sans-serif;
  font-size: 16px;
  transition: border-color 0.2s;
}

.form-group input:focus,
.form-group textarea:focus,
.form-group select:focus {
  outline: none;
  border-color: rgba(65, 214, 195, 0.5);
  background: rgba(255, 255, 255, 0.08);
}

.form-group textarea {
  resize: vertical;
}

.form-group select {
  cursor: pointer;
}

.form-status {
  min-height: 20px;
  color: #41d6c3;
  font-size: 14px;
  margin-bottom: 12px;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .hero-critical {
    padding: 100px 0 60px;
  }

  .architecture-diagram {
    gap: 12px;
  }

  .architecture-entity {
    min-width: 120px;
    padding: 24px 16px;
  }

  .credibility-metric {
    font-size: 36px;
  }

  .hero-critical .hero-tagline {
    font-size: 18px;
  }
}
</style>

<main>
    <!-- Hero Section with Critical Performance Optimization -->
    <section class="hero-critical">
        <div class="wrapper hero-content">
            <div class="hero-eyebrow">ChefOps Operations Platform</div>
            <h1>We keep kitchens running and systems secure.</h1>
            <p class="hero-tagline">
                ChefOps is the invisible backbone of operational reliability for food-service businesses. 
                We anticipate issues, respond instantly, and enable your business to function without ever thinking about security or infrastructure.
            </p>
            <div class="hero-ctas">
                <a class="cta" href="#services">Explore Services</a>
                <a class="ghost" href="#credibility">Learn More</a>
            </div>
        </div>
    </section>

    <!-- Core Services Section -->
    <section id="services" class="services-showcase">
        <div class="wrapper">
            <div class="section-head">
                <div>
                    <h2>Core Services</h2>
                    <p class="section-muted">ChefOps operates quietly in the background, handling the four pillars of operational reliability.</p>
                </div>
            </div>
            <div class="services-grid">
                <div class="service-card">
                    <div class="service-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <circle cx="12" cy="12" r="10"></circle>
                            <polyline points="12 6 12 12 16 14"></polyline>
                        </svg>
                    </div>
                    <h3>Monitoring & Alerting</h3>
                    <p>Real-time visibility into your operations with context-aware alerts that cut through noise. We watch so you don't have to.</p>
                    <ul class="service-features">
                        <li>24/7 system monitoring</li>
                        <li>Intelligent alert routing</li>
                        <li>Custom dashboards</li>
                    </ul>
                </div>

                <div class="service-card">
                    <div class="service-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="3" y="11" width="18" height="11"></rect>
                            <path d="M7 11V7a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v4"></path>
                            <circle cx="12" cy="16" r="1"></circle>
                        </svg>
                    </div>
                    <h3>Identity & Access Control</h3>
                    <p>Secure role-based access management with modern authentication. Control who touches your systems, and trust the process.</p>
                    <ul class="service-features">
                        <li>SSO & MFA deployment</li>
                        <li>Least-privilege enforcement</li>
                        <li>Audit-ready compliance</li>
                    </ul>
                </div>

                <div class="service-card">
                    <div class="service-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline>
                        </svg>
                    </div>
                    <h3>Incident Response</h3>
                    <p>When things go wrong, we respond instantly with tested playbooks. No panic, no delays—just calm competence under pressure.</p>
                    <ul class="service-features">
                        <li>24/7 IR hotline</li>
                        <li>Runbook automation</li>
                        <li>Post-incident reviews</li>
                    </ul>
                </div>

                <div class="service-card">
                    <div class="service-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2z"></path>
                            <path d="M12 6v6l4 2"></path>
                        </svg>
                    </div>
                    <h3>Legacy System Support</h3>
                    <p>Modern security for older infrastructure. We bridge the gap between what you have and what you need, without forced rip-and-replace.</p>
                    <ul class="service-features">
                        <li>Compatibility audits</li>
                        <li>Graceful migrations</li>
                        <li>Ongoing support</li>
                    </ul>
                </div>
            </div>
        </div>
    </section>

    <!-- ChefOps as Secure Intermediary -->
    <section id="architecture" class="architecture-section">
        <div class="wrapper">
            <div class="section-head">
                <div>
                    <h2>The ChefOps Difference</h2>
                    <p class="section-muted">We sit between you and your infrastructure as a trusted, security-forward intermediary.</p>
                </div>
            </div>
            <div class="architecture-diagram">
                <div class="architecture-entity clients">
                    <div class="entity-icon">🏢</div>
                    <div class="entity-label">Your Business</div>
                </div>
                <div class="architecture-connector">→</div>
                <div class="architecture-entity chefops">
                    <div class="entity-label">ChefOps</div>
                    <div class="entity-sublabel">Control • Visibility • Response</div>
                </div>
                <div class="architecture-connector">→</div>
                <div class="architecture-entity infrastructure">
                    <div class="entity-icon">⚙️</div>
                    <div class="entity-label">Your Infrastructure</div>
                </div>
            </div>
            <p class="architecture-text">
                We never make business decisions—we enable them. By operating transparently at the layer between leadership and infrastructure, ChefOps ensures every team member has the visibility and control they need, without the noise.
            </p>
        </div>
    </section>

    <!-- Credibility & Trust Signals -->
    <section id="credibility" class="credibility-section">
        <div class="wrapper">
            <div class="section-head">
                <div>
                    <h2>Built for Reliable Operations</h2>
                    <p class="section-muted">We bring discipline, transparency, and proven expertise to every engagement.</p>
                </div>
            </div>

            <!-- Key Metrics -->
            <div class="credibility-grid">
                <div class="credibility-item">
                    <div class="credibility-metric">99.9%</div>
                    <div class="credibility-label">Uptime across managed infrastructure</div>
                </div>
                <div class="credibility-item">
                    <div class="credibility-metric">&lt;15m</div>
                    <div class="credibility-label">Mean time to incident acknowledgment</div>
                </div>
                <div class="credibility-item">
                    <div class="credibility-metric">100%</div>
                    <div class="credibility-label">Change audit readiness</div>
                </div>
                <div class="credibility-item">
                    <div class="credibility-metric">24/7</div>
                    <div class="credibility-label">Incident response availability</div>
                </div>
            </div>

            <!-- Core Value Propositions -->
            <h3 style="margin-top: 80px; color: #fff; text-align: center; margin-bottom: 40px;">What Sets Us Apart</h3>
            <div class="value-props">
                <div class="value-prop">
                    <h4>Trust Through Transparency</h4>
                    <p>Real-time visibility into decisions, changes, and incidents. No hidden processes. No surprises.</p>
                </div>
                <div class="value-prop">
                    <h4>Uptime, Not Busy-Work</h4>
                    <p>We focus on what matters: keeping systems available. Compliance follows naturally from good practices.</p>
                </div>
                <div class="value-prop">
                    <h4>Instant Response, Not Escalation</h4>
                    <p>Our team acts immediately with tested playbooks. Incidents don't wait for committees.</p>
                </div>
                <div class="value-prop">
                    <h4>Modern Security, Minimal Friction</h4>
                    <p>Zero-trust architecture that feels effortless. Security and usability aren't opposing forces.</p>
                </div>
                <div class="value-prop">
                    <h4>Business Context, Not Technical Jargon</h4>
                    <p>Reports and alerts speak your language. You understand the impact and business implications.</p>
                </div>
                <div class="value-prop">
                    <h4>Legacy Support Without Compromise</h4>
                    <p>We enhance what you have while enabling safe paths forward. No forced replacements.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Strong Call-to-Action -->
    <section class="cta-section">
        <div class="wrapper">
            <h2>Ready to delegate operations?</h2>
            <p>Let's talk about how ChefOps can be the reliable backbone your business needs.</p>
            <div class="hero-actions">
                <a class="cta js-open-modal" data-target="#contact-modal" href="#contact-modal">Start a Conversation</a>
                <a class="ghost js-open-modal" data-target="#ticket-modal" href="#ticket-modal">Submit a Ticket</a>
            </div>
        </div>
    </section>

    <!-- Contact Modal -->
    <div id="contact-modal" class="modal">
        <div class="modal-overlay"></div>
        <div class="modal-content">
            <button class="js-close-modal modal-close">×</button>
            <h2>Get in Touch</h2>
            <form class="js-request-form" method="POST">
                <input type="hidden" name="request_type" value="contact">
                <div class="form-group">
                    <label for="contact-name">Name</label>
                    <input type="text" id="contact-name" name="name" required>
                </div>
                <div class="form-group">
                    <label for="contact-email">Email</label>
                    <input type="email" id="contact-email" name="email" required>
                </div>
                <div class="form-group">
                    <label for="contact-phone">Phone (optional)</label>
                    <input type="tel" id="contact-phone" name="phone">
                </div>
                <div class="form-group">
                    <label for="contact-message">Message</label>
                    <textarea id="contact-message" name="message" rows="5" required></textarea>
                </div>
                <div class="form-status"></div>
                <button type="submit" class="cta">Send Message</button>
            </form>
        </div>
    </div>

    <!-- Ticket Modal -->
    <div id="ticket-modal" class="modal">
        <div class="modal-overlay"></div>
        <div class="modal-content">
            <button class="js-close-modal modal-close">×</button>
            <h2>Submit a Ticket</h2>
            <form class="js-request-form" method="POST">
                <input type="hidden" name="request_type" value="ticket">
                <div class="form-group">
                    <label for="ticket-name">Name</label>
                    <input type="text" id="ticket-name" name="name" required>
                </div>
                <div class="form-group">
                    <label for="ticket-email">Email</label>
                    <input type="email" id="ticket-email" name="email" required>
                </div>
                <div class="form-group">
                    <label for="ticket-category">Category</label>
                    <select id="ticket-category" name="category" required>
                        <option value="">Select a category</option>
                        <option value="incident">Incident</option>
                        <option value="change">Change Request</option>
                        <option value="access">Access Request</option>
                        <option value="other">Other</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="ticket-message">Description</label>
                    <textarea id="ticket-message" name="message" rows="5" required></textarea>
                </div>
                <div class="form-status"></div>
                <button type="submit" class="cta">Submit Ticket</button>
            </form>
        </div>
    </div>
</main>


<?php get_footer(); ?>
