# Skills Knowledge Base

> Knowledge base for Project Managers, Analysts and Common skills

## Structure

```
skills-knowledge-base/
├── Common/                    # Common skills for all roles
│   ├── README.md
│   ├── Meeting-protocol/      # Meeting Protocol skill for opencode
│   │   ├── SKILL.md
│   │   ├── corrections.json
│   │   └── README.md
├── PM/                        # Project Manager skills
│   └── README.md
├── Analyst/                   # Analyst skills
│   └── README.md
├── setup-skill-links.ps1      # Script to create junction links for opencode
└── CHANGELOG.md
```

## Setup

After cloning, run this script in PowerShell (as admin) to register skills with opencode:

```powershell
.\setup-skill-links.ps1
```

To remove links:
```powershell
.\setup-skill-links.ps1 -Remove
```

## Sections

| Folder | Description |
|--------|-------------|
| [Common](./Common/) | Skills and documents applicable to all roles |
| [PM](./PM/) | Project Manager specific skills and materials |
| [Analyst](./Analyst/) | Analyst specific skills and materials |

## Contributing

1. Create a branch from `main`
2. Add or update files in the appropriate folder
3. Open a Pull Request with a clear description
4. Get reviewed and merged

## Maintainer

[@NevzoRRo](https://github.com/NevzoRRo)
