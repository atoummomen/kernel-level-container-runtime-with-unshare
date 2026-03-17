# Runtime Engine Design

## Objective

After manually validating container isolation, filesystem switching, and networking, the next step is to design a minimal runtime engine that automates these operations.

The goal is to convert the manual workflow into a reusable execution model.

This phase focuses on architecture and execution flow, not implementation details.

---

## Design Philosophy

The runtime engine must:

- Be minimal
- Use only Linux kernel primitives
- Avoid external container libraries
- Remain fully transparent in its behavior
- Execute a target program as PID 1 inside the container

The engine is intentionally simple to preserve clarity and educational value.

---

## Execution Model

The runtime engine will:

1. Create required namespaces
2. Configure mount isolation
3. Prepare the root filesystem
4. Switch root using pivot_root
5. Mount required virtual filesystems
6. Configure networking
7. Execute the target program using exec

The final process replaces the engine process itself, becoming PID 1 inside the container.

---

## Why exec Is Critical

The final step of the engine must be:

```
exec "$@"
```

This ensures:

- The target program replaces the engine process
- The target program becomes PID 1
- No unnecessary parent process remains
- Signal handling behaves correctly

Without exec, the engine would remain as PID 1 and break container semantics.

---

## Separation of Concerns

The project separates responsibilities:

docs/            → Documentation and explanation  
scripts/         → Engine logic and automation  
architecture/    → Visual system design  

This separation ensures clarity and maintainability.

---

## Runtime Responsibilities

The engine must control:

- Namespace lifecycle
- Mount propagation rules
- Root switching
- Virtual filesystem mounts
- Interface configuration
- Routing configuration
- Process execution

The engine does not manage:

- Image registry
- Container orchestration
- Resource scheduling
- Logging subsystems

It remains a single-node experimental runtime.

---

## Architectural Boundaries

The system has two main boundaries:

Host Boundary  
Contains:
- Bridge (br0)
- NAT rules
- Routing
- Uplink interface

Container Boundary  
Contains:
- Isolated PID namespace
- Isolated mount namespace
- Isolated network namespace
- Container root filesystem
- Target process (PID 1)

These boundaries are strictly enforced through namespace isolation.

---

## Design Outcome

At this stage:

- Manual steps are validated
- Networking is proven functional
- Filesystem isolation is confirmed
- Kernel primitives are understood

The next step is translating this design into a minimal executable engine script.
