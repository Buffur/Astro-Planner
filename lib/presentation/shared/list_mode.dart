/// What a tap on a rig, target or site does (S9.1; RD-07, TD-053; E.1,
/// D9-1). The Library **manages** its lists: a tap opens the item and never
/// changes the plan or the active site. The planner, Tonight's context line
/// and the first run open the same lists to **choose** one (`/select/…`).
enum ListMode { manage, choose }
