---
applyTo: "**/*.ts,**/*.tsx,**/*.js,**/*.jsx"
---

## Dependency versions

-   yarn 1.22 (don't use npm)
-   react 17
-   use antd (ant design) 4 and not Material UI
-   @ant-design/icons for icons
-   react-query 4 and zustand 4 for state management, not redux
-   forms: use ant design and not formik and yup
-   use package.json scripts for running linting and tests

## General rules

-   always explicitly type return types and params
-   use JSDoc comments, even for one line comments (so they show up in IDEs on variable hover)
-   for short one line JSDocs, use the single line /\*_ comment _/ style

## Atomic design

-   Follow Atomic Design principles

    -   Atom examples: wrapped third party components, Button, Text, Label, Icon, Image, Input, Checkbox, Radio, Tag, Badge, Avatar, Spinner, Divider, Tooltip, Heading, Link, TextArea, Select, Switch, ErrorText, HelperText, FormLabel, Skeleton, CloseButton, Loader, HorizontalRule, StatusDot, IconButton
    -   Molecule examples: FormField, FieldWithError, InputGroup, CardHeader, TableRow, ModalHeader, ModalFooter, SearchBar, FilterBar, UserInfoBlock, ButtonGroup, StatBadge, DropdownMenu, TabBar, ProgressStep, PaginationControls, ToastMessage, AvatarWithName, LabelValueRow, TagList, DateRangePicker, RatingStars, FileInputGroup, TooltipWithIcon, ToggleSwitchGroup, SelectWithLabel, IconButtonWithBadge, InfoBanner, StepIndicator, TextWithSubtext
    -   Organism examples: All Forms, All Modals, Cards, Tables, Sidebar, TopNav, SettingsPanel, NotificationList, ReportViewer, Charts, ChartsPanel, FileUploadSection, StepperForm, UserManagementPanel, AuditTrail, SearchResultsPanel, FilterSidebar, DetailViewPanel, CommentThread

-   Use WAI-ARIA roles to help with component naming and type inference

### Component colocation

Prefer

```
src/
└── organisms/
    └── forms/
        └── ContactForm/
            ├── index.tsx
            ├── ContactFormFooterMolecule.tsx
            └── ContactFormFiltersMolecule.tsx
```

and avoid this

```
src/
├── molecules/
│   ├── ContactFormFooter.tsx
│   └── ContactFormFilters.tsx
└── organisms/
    └── forms/
        └── ContactForm/
            └── index.tsx
```

## TypeScript

-   use typescript for all new code
-   don't use TypeScript enums: use objects as const instead
-   generics: provide meaningful T names (e.g. TItem, TResponse, TData, TError)
-   Do not use the type `any`
- always use type imports instead of value imports for types, e.g. `import type { MyType } from 'my-module'`

## React

-   don't use React.FC type for components
