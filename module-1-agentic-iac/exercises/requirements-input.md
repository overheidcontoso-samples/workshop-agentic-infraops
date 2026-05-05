# Infrastructure Request — Team Horizon Customer Portal

**From:** Lisa Jensen, Product Owner — Team Horizon
**Date:** 2026-04-28
**Priority:** Medium

---

## Business Context

Team Horizon is building a customer portal where our B2B clients can view their orders, download invoices, and manage their account settings. We expect around 500 active users in the first 6 months, growing to 2,000 within a year. The portal needs to be live by end of Q3 2026.

---

## Functional Requirements

- **Web application** — A responsive web frontend with a REST API backend
- **Database** — Relational database for customer data, orders, and invoices
- **File storage** — Blob storage for PDF invoices and uploaded documents
- **Authentication** — Integration with Azure Entra ID for B2B user login
- **Email notifications** — Send transactional emails (order confirmations, invoice alerts)
- **Background jobs** — Scheduled tasks for report generation and data sync with our ERP system

## Non-Functional Requirements

- **Availability** — 99.5% uptime SLA for the portal (business hours are most critical)
- **Security** — All data encrypted at rest and in transit; no public database endpoints
- **Performance** — Page load time under 2 seconds for 95th percentile
- **Region** — Deploy in West Europe (primary); no multi-region needed for now
- **Compliance** — GDPR compliance required; data must stay in EU

## Constraints

- **Timeline** — Infrastructure must be ready within 4 weeks for the dev team to start deploying
- **Team skills** — Dev team is familiar with .NET 8 and React; limited Kubernetes experience
- **Budget** — Max €500/month for non-production environments, €2,000/month for production

---

*Please set up the infrastructure so our team can start deploying their application. We don't need Kubernetes — something simpler would be preferred. Thanks!*
