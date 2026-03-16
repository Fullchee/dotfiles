---
applyTo: "**/*.ts,**/*.tsx,**/*.js,**/*.jsx"
---

## Dependency versions

- yarn 1.22 (don't use npm)
- react 17
- use antd (ant design) 4 and not Material UI
- @ant-design/icons for icons
- react-query 4 and zustand 4 for state management, not redux
- forms: use ant design and not formik and yup
- use package.json scripts for running linting and tests

## General rules

- always explicitly type return types and params
- use JSDoc comments, even for one line comments (so they show up in IDEs on variable hover)
- for short one line JSDocs, use the single line /\*_ comment _/ style
- don't explicitly import `import React from "react";`
- always use absolute imports
- use ESM imports for antd, material, @ant-design/icons like `import TeamOutlined from "@ant-design/icons/TeamOutlined";` and not `import { TeamOutlined } from "@ant-design/icons";`

## TypeScript

- use typescript for all new code
- don't use TypeScript enums: use objects as const instead
- generics: provide meaningful T names (e.g. TItem, TResponse, TData, TError)
- Do not use the type `any`
- always use type imports instead of value imports for types, e.g. `import type { MyType } from 'my-module'`

## React

- don't use React.FC type for components

## Styling

- when using colors, import from `colors.ts`
