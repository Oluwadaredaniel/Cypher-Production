# GITHUB BEST PRACTICES FOR CYPHER

## REPOSITORY STRUCTURE
```
Cypher/
├── .github/
│   ├── workflows/         # CI/CD pipelines
│   ├── ISSUE_TEMPLATE/    # Bug/Feature templates
│   └── PULL_REQUEST_TEMPLATE.md
├── mobile/                # Flutter Mobile App
├── pc/                    # Flutter PC App
├── backend/               # Python Backend
├── docs/                  # Project Documentation
├── CHANGELOG.md
├── LICENSE
├── README.md
└── .gitignore
```

---

## COMMIT MESSAGE FORMAT (Conventional Commits)
`type(scope): subject`

### Types
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactor
- `docs`: Documentation
- `style`: Code style (formatting)
- `chore`: Build/dependencies
- `perf`: Performance improvement
- `security`: Security fix

---

## BRANCH NAMING
- `main`: Production code (stable)
- `develop`: Development (integration)
- `feature/name`: New features
- `bugfix/name`: Bug fixes
- `hotfix/name`: Critical production fixes

---

## PULL REQUEST PROCESS
1. Create branch from `develop`.
2. Make changes and write tests.
3. Submit PR with description.
4. Self-review first.
5. Address review comments.
6. Merge to `develop` (squash).
7. Delete branch.

---

## CI/CD PIPELINES
- **On push to feature branch**: Build APK/EXE, run tests, check code style, run security scan.
- **On merge to main**: Tag release, create GitHub release, build & sign final artifacts, upload to releases.
