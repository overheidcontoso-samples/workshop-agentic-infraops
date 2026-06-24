# draw.io Shape Libraries

Reference guide for all built-in shape libraries. Enable via `View > Shapes` in the draw.io editor (or VS Code extension shape panel).

---

## Library Catalog

### General

**Enable**: Always active by default

Common shapes for any diagram type.

| Shape | Style Key | Use For |
| ------- | ----------- | --------- |
| Rectangle | *(default)* | Boxes, steps, components |
| Rounded Rectangle | `rounded=1;` | Softer process boxes |
| Ellipse | `ellipse;` | States, start/end |
| Triangle | `triangle;` | Arrows, gates |
| Diamond | `rhombus;` | Decisions |
| Hexagon | `shape=hexagon;` | Labels, tech icons |
| Cloud | `shape=cloud;` | Cloud services |
| Cylinder | `shape=cylinder3;` | Databases |
| Note | `shape=note;` | Annotations |
| Document | `shape=document;` | Files |
| Arrow shapes | Various `mxgraph.arrows2.*` | Flow directions |
| Callouts | `shape=callout;` | Speech bubbles |

---

### Flowchart

**Enable**: `View > Shapes > Flowchart`  
**Shape prefix**: `mxgraph.flowchart.`

Standard ANSI/ISO flowchart symbols.

| Symbol | Style String | ANSI Name |
| -------- | ------------- | ----------- |
| Start / End | `ellipse;` | Terminal |
| Process (rectangle) | `rounded=1;` | Process |
| Decision | `rhombus;` | Decision |
| I/O (parallelogram) | `shape=mxgraph.flowchart.io;` | Data |
| Predefined Process | `shape=mxgraph.flowchart.predefined_process;` | Predefined Process |
| Manual Operation | `shape=mxgraph.flowchart.manual_operation;` | Manual Operation |
| Manual Input | `shape=mxgraph.flowchart.manual_input;` | Manual Input |
| Database | `shape=mxgraph.flowchart.database;` | Direct Access Storage |
| Document | `shape=mxgraph.flowchart.document;` | Document |
| Multiple Documents | `shape=mxgraph.flowchart.multi-document;` | Multiple Documents |
| On-page Connector | `ellipse;` (small, 30×30) | Connector |
| Off-page Connector | `shape=mxgraph.flowchart.off_page_connector;` | Off-page Connector |
| Preparation | `shape=mxgraph.flowchart.preparation;` | Preparation |
| Delay | `shape=mxgraph.flowchart.delay;` | Delay |
| Display | `shape=mxgraph.flowchart.display;` | Display |
| Internal Storage | `shape=mxgraph.flowchart.internal_storage;` | Internal Storage |
| Sort | `shape=mxgraph.flowchart.sort;` | Sort |
| Extract | `shape=mxgraph.flowchart.extract;` | Extract |
| Merge | `shape=mxgraph.flowchart.merge;` | Merge |
| Or | `shape=mxgraph.flowchart.or;` | Or |
| Annotation | `shape=mxgraph.flowchart.annotation;` | Annotation |
| Card | `shape=mxgraph.flowchart.card;` | Punched Card |

**Complete flowchart example style strings:**

```text
Process:          rounded=1;whiteSpace=wrap;html=1;
Decision:         rhombus;whiteSpace=wrap;html=1;
Start/End:        ellipse;whiteSpace=wrap;html=1;
Database:         shape=mxgraph.flowchart.database;whiteSpace=wrap;html=1;
Document:         shape=mxgraph.flowchart.document;whiteSpace=wrap;html=1;
I/O (Data):       shape=mxgraph.flowchart.io;whiteSpace=wrap;html=1;
```

---

### UML

**Enable**: `View > Shapes > UML`

#### Use Case Diagrams

| Shape | Style String |
| ------- | ------------- |
| Actor | `shape=mxgraph.uml.actor;whiteSpace=wrap;html=1;` |
| Use Case (ellipse) | `ellipse;whiteSpace=wrap;html=1;` |
| System Boundary | `swimlane;startSize=30;whiteSpace=wrap;html=1;` |

#### Class Diagrams

Use swimlane containers for class boxes:

```xml
<!-- Class container -->
<mxCell value="«interface»&#xa;IOrderService" 
        style="swimlane;fontStyle=1;align=center;startSize=30;whiteSpace=wrap;html=1;"
        vertex="1" parent="1">
  <mxGeometry x="200" y="100" width="200" height="160" as="geometry" />
</mxCell>

<!-- Attributes (child of class) -->
<mxCell value="+ id: string&#xa;+ status: string" 
        style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;overflow=hidden;html=1;"
        vertex="1" parent="classId">
  <mxGeometry y="30" width="200" height="60" as="geometry" />
</mxCell>

<!-- Method separator line -->
<mxCell value="" style="line;strokeWidth=1;fillColor=none;" vertex="1" parent="classId">
  <mxGeometry y="90" width="200" height="10" as="geometry" />
</mxCell>

<!-- Methods (child of class) -->
<mxCell value="+ create(): Order&#xa;+ cancel(): void"
        style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;overflow=hidden;html=1;"
        vertex="1" parent="classId">
  <mxGeometry y="100" width="200" height="60" as="geometry" />
</mxCell>
```

#### UML Relationship Arrows

| Relationship | Style String |
| ------------- | ------------- |
| Inheritance (extends) | `edgeStyle=orthogonalEdgeStyle;html=1;endArrow=block;endFill=0;` |
| Implementation (implements) | `edgeStyle=orthogonalEdgeStyle;dashed=1;html=1;endArrow=block;endFill=0;` |
| Association | `edgeStyle=orthogonalEdgeStyle;html=1;endArrow=open;endFill=0;` |
| Dependency | `edgeStyle=orthogonalEdgeStyle;dashed=1;html=1;endArrow=open;endFill=0;` |
| Aggregation | `edgeStyle=orthogonalEdgeStyle;html=1;startArrow=diamond;startFill=0;endArrow=none;` |
| Composition | `edgeStyle=orthogonalEdgeStyle;html=1;startArrow=diamond;startFill=1;endArrow=none;` |

#### Component Diagram

| Shape | Style String |
| ------- | ------------- |
| Component | `shape=component;align=left;spacingLeft=36;whiteSpace=wrap;html=1;` |
| Interface (lollipop) | `ellipse;whiteSpace=wrap;html=1;aspect=fixed;` (small circle) |
| Port | `shape=mxgraph.uml.port;` |
| Node | `shape=mxgraph.uml.node;whiteSpace=wrap;html=1;` |
| Artifact | `shape=mxgraph.uml.artifact;whiteSpace=wrap;html=1;` |

#### Sequence Diagrams

| Shape | Style String |
| ------- | ------------- |
| Actor | `shape=mxgraph.uml.actor;whiteSpace=wrap;html=1;` |
| Lifeline (object) | `shape=umlLifeline;startSize=40;whiteSpace=wrap;html=1;` |
| Activation box | `shape=umlActivation;whiteSpace=wrap;html=1;` |
| Sync message | `edgeStyle=elbowEdgeStyle;elbow=vertical;html=1;endArrow=block;endFill=1;` |
| Async message | `edgeStyle=elbowEdgeStyle;elbow=vertical;html=1;endArrow=open;endFill=0;` |
| Return | `edgeStyle=elbowEdgeStyle;elbow=vertical;dashed=1;html=1;endArrow=open;endFill=0;` |
| Self-call | `edgeStyle=elbowEdgeStyle;elbow=vertical;exitX=1;exitY=0.3;entryX=1;entryY=0.5;html=1;` |

#### State Diagrams

| Shape | Style String |
| ------- | ------------- |
| Initial state (solid circle) | `ellipse;html=1;aspect=fixed;fillColor=#000000;strokeColor=#000000;` |
| State | `rounded=1;whiteSpace=wrap;html=1;arcSize=50;` |
| Final state | `shape=doubleEllipse;fillColor=#000000;strokeColor=#000000;` |
| Transition | `edgeStyle=orthogonalEdgeStyle;html=1;endArrow=block;endFill=1;` |
| Fork/Join | `shape=mxgraph.uml.fork_or_join;html=1;fillColor=#000000;` |

---

### Entity Relationship (ER Diagrams)

**Enable**: `View > Shapes > Entity Relation`

#### Modern ER Tables (crow's foot notation)

```xml
<!-- Table container -->
<mxCell id="tbl-orders" value="orders"
        style="shape=table;startSize=30;container=1;collapsible=1;childLayout=tableLayout;fillColor=#dae8fc;strokeColor=#6c8ebf;fontStyle=1;"
        vertex="1" parent="1">
  <mxGeometry x="80" y="80" width="240" height="210" as="geometry" />
</mxCell>

<!-- Column row -->
<mxCell id="col-id" value=""
        style="shape=tableRow;horizontal=0;startSize=0;swimmilaneHead=0;swimlaneBody=0;fillColor=none;collapsible=0;dropTarget=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;"
        vertex="1" parent="tbl-orders">
  <mxGeometry y="30" width="240" height="30" as="geometry" />
</mxCell>

<!-- PK marker cell -->
<mxCell value="PK" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;fontStyle=1;overflow=hidden;"
        vertex="1" parent="col-id">
  <mxGeometry width="40" height="30" as="geometry" />
</mxCell>

<!-- Column name cell -->
<mxCell value="id" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;overflow=hidden;"
        vertex="1" parent="col-id">
  <mxGeometry x="40" width="140" height="30" as="geometry" />
</mxCell>

<!-- Data type cell -->
<mxCell value="UUID" style="shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;bottom=0;right=0;overflow=hidden;fontStyle=2;"
        vertex="1" parent="col-id">
  <mxGeometry x="180" width="60" height="30" as="geometry" />
</mxCell>
```

#### ER Relationship Connectors (crow's foot)

| Cardinality | Style String |
| ------------- | ------------- |
| One-to-one | `edgeStyle=entityRelationEdgeStyle;html=1;startArrow=ERmandOne;endArrow=ERmandOne;startFill=1;endFill=1;` |
| One-to-many | `edgeStyle=entityRelationEdgeStyle;html=1;startArrow=ERmandOne;endArrow=ERmany;startFill=1;endFill=1;` |
| Zero-to-many | `edgeStyle=entityRelationEdgeStyle;html=1;startArrow=ERmandOne;endArrow=ERzeroToMany;startFill=1;endFill=0;` |
| Zero-to-one | `edgeStyle=entityRelationEdgeStyle;html=1;startArrow=ERmandOne;endArrow=ERzeroToOne;startFill=1;endFill=0;` |
| Many-to-many | `edgeStyle=entityRelationEdgeStyle;html=1;startArrow=ERmany;endArrow=ERmany;startFill=1;endFill=1;` |

---

### Network / Infrastructure

**Enable**: `View > Shapes > Networking`

| Shape | Style String |
| ------- | ------------- |
| Generic server | `shape=server;html=1;whiteSpace=wrap;` |
| Web server | `shape=mxgraph.network.web_server;` |
| Database server | `shape=mxgraph.network.database;` |
| Laptop | `shape=mxgraph.network.laptop;` |
| Desktop | `shape=mxgraph.network.desktop;` |
| Mobile phone | `shape=mxgraph.network.mobile;` |
| Router | `shape=mxgraph.cisco.routers.router;` |
| Switch | `shape=mxgraph.cisco.switches.workgroup_switch;` |
| Firewall | `shape=mxgraph.cisco.firewalls.firewall;` |
| Cloud (generic) | `shape=cloud;` |
| Internet | `shape=mxgraph.network.internet;` |
| Load balancer | `shape=mxgraph.network.load_balancer;` |

---

### BPMN 2.0

**Enable**: `View > Shapes > BPMN`  
**Shape prefix**: `shape=mxgraph.bpmn.*`

| Shape | Style String |
| ------- | ------------- |
| Start event | `shape=mxgraph.bpmn.shape;perimeter=mxPerimeter.ellipsePerimeter;symbol=general;verticalLabelPosition=bottom;` |
| End event | `shape=mxgraph.bpmn.shape;perimeter=mxPerimeter.ellipsePerimeter;symbol=terminate;verticalLabelPosition=bottom;` |
| Task | `shape=mxgraph.bpmn.shape;perimeter=mxPerimeter.rectanglePerimeter;symbol=task;` |
| Exclusive gateway | `shape=mxgraph.bpmn.shape;perimeter=mxPerimeter.rhombusPerimeter;symbol=exclusiveGw;` |
| Parallel gateway | `shape=mxgraph.bpmn.shape;perimeter=mxPerimeter.rhombusPerimeter;symbol=parallelGw;` |
| Sub-process | `shape=mxgraph.bpmn.shape;perimeter=mxPerimeter.rectanglePerimeter;symbol=subProcess;` |
| Sequence flow | `edgeStyle=orthogonalEdgeStyle;html=1;endArrow=block;endFill=1;` |
| Message flow | `edgeStyle=orthogonalEdgeStyle;dashed=1;html=1;endArrow=block;endFill=0;` |
| Pool | `shape=pool;startSize=30;horizontal=1;` |
| Lane | `swimlane;startSize=30;` |

---

### Mockup / Wireframe

**Enable**: `View > Shapes > Mockup`

| Shape | Style String |
| ------- | ------------- |
| Button | `shape=mxgraph.mockup.forms.button;` |
| Input field | `shape=mxgraph.mockup.forms.text1;` |
| Checkbox | `shape=mxgraph.mockup.forms.checkbox;` |
| Dropdown | `shape=mxgraph.mockup.forms.comboBox;` |
| Browser window | `shape=mxgraph.mockup.containers.browser;` |
| Mobile screen | `shape=mxgraph.mockup.containers.smartphone;` |
| List | `shape=mxgraph.mockup.containers.list;` |
| Table | `shape=mxgraph.mockup.containers.table;` |

---

### Kubernetes

**Enable**: `View > Shapes > Kubernetes`

| Resource | Style String |
| ---------- | ------------- |
| Pod | `shape=mxgraph.kubernetes.pod;` |
| Deployment | `shape=mxgraph.kubernetes.deploy;` |
| Service | `shape=mxgraph.kubernetes.svc;` |
| Ingress | `shape=mxgraph.kubernetes.ing;` |
| ConfigMap | `shape=mxgraph.kubernetes.cm;` |
| Secret | `shape=mxgraph.kubernetes.secret;` |
| PersistentVolume | `shape=mxgraph.kubernetes.pv;` |
| Namespace | `shape=mxgraph.kubernetes.ns;` |
| Node | `shape=mxgraph.kubernetes.node;` |

---

### Azure (official `azure2` SVG icon set — RECOMMENDED)

**Enable**: `View > More Shapes > Networking > Azure` (uses the official Microsoft Azure icon SVGs bundled with draw.io desktop/web; available since draw.io 14.x)

**Critical:** the modern Azure icons are NOT mxgraph stencils — they are bundled **SVG images** loaded via `image=img/lib/azure2/<category>/<File>.svg`. Always use this `image=...` pattern, NOT `shape=mxgraph.azure.*` (the old stencil set is incomplete and most names render as a blue square placeholder).

**Standard style string** for any Azure icon:

```
image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/<CATEGORY>/<FILENAME>.svg;
```

Recommended cell geometry: `width=48 height=48` for the icon itself, with the label rendered below via `verticalLabelPosition=bottom;verticalAlign=top;`.

**Verification workflow** (do this before bulk-generating icons):

1. In draw.io, drag one icon from the target category onto the canvas
2. Right-click → **Edit Style…**
3. Copy the `image=img/lib/azure2/...svg` path — that is the ground truth
4. Use the exact category folder + filename in your generated XML

**Category folders under `img/lib/azure2/`** (drag-and-drop tested in draw.io 24+):

| Category folder | Contents |
| --- | --- |
| `ai_machine_learning` | Azure OpenAI, AI Foundry, Cognitive Services, Content Safety, Azure ML, Cognitive Search, Speech, Document Intelligence |
| `analytics` | Synapse, Stream Analytics, Data Factory, Event Hubs, Microsoft Fabric |
| `app_services` | App Service, App Service Plan, Static Web Apps |
| `compute` | App Services, Function Apps, Virtual Machines, Container Instances |
| `containers` | Kubernetes Services (AKS), Container Apps, Container Registries |
| `databases` | Azure SQL, Cosmos DB, MySQL, PostgreSQL, Managed Instance |
| `devops` | Azure DevOps, GitHub, Pipelines |
| `general` | Subscriptions, Resource Groups, Tags, Information, Cloud |
| `identity` | Microsoft Entra ID, Managed Identity, Key Vaults |
| `integration` | API Management Services, Logic Apps, Service Bus, Event Grid |
| `management_governance` | Application Insights, Log Analytics Workspaces, Monitor, Cost Management and Billing, Policy, Microsoft Purview, Resource Manager |
| `networking` | Virtual Networks, Front Door and CDN Profiles, Application Gateway, Load Balancer, DNS Zones, Private Endpoint |
| `security` | Defender for Cloud, Microsoft Sentinel, Web Application Firewall |
| `storage` | Storage Accounts, Blob Storage, Data Lake Storage Gen2, Storage Browser |
| `web` | App Service, App Service Plan, API Connections |

**Common verified style strings** (file path is case-sensitive on Linux/Mac; PascalCase with underscores):

| Service | Style string |
| --- | --- |
| AKS | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/containers/Kubernetes_Services.svg;` |
| Container Apps / Instances | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/containers/Container_Instances.svg;` *(no separate Container_Apps.svg exists)* |
| Container Registry | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/containers/Container_Registries.svg;` |
| App Service | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/app_services/App_Services.svg;` |
| Function App | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/compute/Function_Apps.svg;` |
| API Management | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/integration/API_Management_Services.svg;` |
| Logic Apps | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/integration/Logic_Apps.svg;` |
| Entra ID / Azure AD | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/identity/Azure_Active_Directory.svg;` *(filename in repo is still Azure_Active_Directory.svg, not Microsoft_Entra_ID.svg)* |
| Key Vault | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/security/Key_Vaults.svg;` *(lives under `security/`, not `identity/`)* |
| Virtual Network | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/networking/Virtual_Networks.svg;` |
| Front Door / CDN | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/networking/CDN_Profiles.svg;` *(use CDN_Profiles for combined Front Door/CDN)* |
| Azure OpenAI | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/ai_machine_learning/Azure_OpenAI.svg;` |
| AI Foundry / AI Studio | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/ai_machine_learning/AI_Studio.svg;` *(no AI_Foundry.svg — Foundry is the rebrand of AI Studio in the repo)* |
| Cognitive Services | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/ai_machine_learning/Cognitive_Services.svg;` |
| AI Content Safety | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/ai_machine_learning/Content_Safety.svg;` |
| Azure Machine Learning | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/ai_machine_learning/Machine_Learning.svg;` *(filename is Machine_Learning.svg, NOT Azure_Machine_Learning.svg)* |
| Azure AI Search | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/ai_machine_learning/Cognitive_Services.svg;` *(no dedicated Cognitive_Search.svg in azure2 — fall back to Cognitive_Services)* |
| Azure SQL | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/databases/Azure_SQL.svg;` |
| Cosmos DB | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/databases/Azure_Cosmos_DB.svg;` |
| Storage Account | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/storage/Storage_Accounts.svg;` |
| Application Insights | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/management_governance/Application_Insights.svg;` |
| Log Analytics | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/management_governance/Log_Analytics_Workspaces.svg;` |
| Azure Monitor | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/management_governance/Monitor.svg;` |
| Cost Management | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/management_governance/Cost_Management_and_Billing.svg;` |
| Azure Policy | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/management_governance/Policy.svg;` |
| Microsoft Purview | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/management_governance/Microsoft_Purview.svg;` |
| Azure DevOps | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/devops/Azure_DevOps.svg;` |
| Synapse / "Fabric" stand-in | `image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/analytics/Azure_Synapse_Analytics.svg;` *(NO Microsoft_Fabric.svg exists in drawio's azure2 set — use Synapse or Data_Lake_Store_Gen1 as substitute)* |

> **Verification reminder.** drawio's `azure2/` SVG set lives at  
> `https://github.com/jgraph/drawio/tree/dev/src/main/webapp/img/lib/azure2/`  
> Browse that repo directly to confirm a filename exists BEFORE generating XML. Filenames are case-sensitive on macOS/Linux. Common gotchas: services in `Identity` panel of drawio actually live under `azure2/security/` (Key_Vaults, Defender), and several brand renames (Entra ID = `Azure_Active_Directory.svg`, AI Foundry = `AI_Studio.svg`) lag behind Microsoft's naming.

**Cell template** (drop-in for `<mxCell>`):

```xml
<mxCell id="az_aks" value="Azure Kubernetes Service&#10;(BD-NEX, EPIF)"
        style="image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/containers/Kubernetes_Services.svg;verticalLabelPosition=bottom;verticalAlign=top;"
        vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="48" height="48" as="geometry" />
</mxCell>
```

**Common mistakes:**

| Symptom | Cause | Fix |
| --- | --- | --- |
| Icon shows as plain blue square | Used legacy `shape=mxgraph.azure.<name>` for a name that does not exist in that stencil set | Switch to `image=img/lib/azure2/...svg` pattern |
| Icon shows as broken-image placeholder | Wrong path: typo in category folder, wrong filename casing, or `.svg` missing | Verify by dragging the actual icon and reading "Edit Style…" |
| Icon visible in drawio web but missing on export | Bundled `azure2` SVGs only resolve inside drawio's image resolver | Use Export → SVG/PNG from inside drawio (resolves correctly), not external XML→SVG converters |
| Label overlaps icon | Default style puts label centered on shape | Add `verticalLabelPosition=bottom;verticalAlign=top;` and make box `48×48` with label space below |

---

## Enabling Libraries in VS Code

Libraries are enabled inside the draw.io editor (which VS Code embeds):

1. Open any `.drawio` or `.drawio.svg` file in VS Code
2. Click the `+` icon in the shape panel (left sidebar) →`Search Shapes` or `More Shapes`
3. Check the library you want to activate
4. Shapes appear in the panel for drag-and-drop

Libraries are stored per-user in draw.io settings (not per-project).

---

## Custom Shape Library Creation

A custom library is an XML file with `.xml` extension loaded via `File > Open Library`:

```xml
<mxlibrary>
  [
    {
      "xml": "&lt;mxCell value=\"Component\" style=\"rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;\" vertex=\"1\"&gt;&lt;mxGeometry width=\"120\" height=\"60\" as=\"geometry\" /&gt;&lt;/mxCell&gt;",
      "w": 120,
      "h": 60,
      "aspect": "fixed",
      "title": "My Component"
    }
  ]
</mxlibrary>
```

Each shape entry contains:
- `xml`: XML-escaped cell definition
- `w` / `h`: Default width/height
- `aspect`: `"fixed"` to lock ratio
- `title`: Name shown in panel

    }
  ]
</mxlibrary>
```
