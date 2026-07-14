# Custom Agents

This folder contains repository-specific agent definitions used by Copilot to route specialized tasks.

## Available Agents
- `Terraform Infrastructure` (`terraform-infra.agent.md`): Implements Azure infrastructure changes in `infrastructure/` using Terraform and bootstrap scripts.
- `Apache Platform Helm OPA` (`apache-platform-helm-opa.agent.md`): Implements AKS platform components with Helm, scripts-first workflows, ConfigMap-first configuration, and OPA/Gatekeeper policy coverage.
- `Code Reviewer` (`code-reviewer.agent.md`): Performs security-focused and domain-aware reviews for branches, PRs, or selected files.

## Authoring Notes
- Agent files use frontmatter with fields like `name`, `description`, `tools`, and `argument-hint`.
- Keep instructions narrowly scoped to one domain and reference the relevant skill file.
- Prefer concrete workflow steps and explicit output formats.

## Repository Boundaries
- Infrastructure tasks: use `Terraform Infrastructure`.
- Platform/Kubernetes/Helm/OPA tasks: use `Apache Platform Helm OPA`.
- Review and security audit tasks: use `Code Reviewer`.
