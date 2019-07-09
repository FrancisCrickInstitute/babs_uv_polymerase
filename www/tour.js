var tour = new Tour({
    name: "tour",
    container: "body",
    smartPlacement: true,
    keyboard: true,
    storage: false,
    steps: [
	{
	    element: "#main_tab",
	    title: "Startup Screen",
	    content: "We'll walk through the main features of the the DNA damage-repair simulator here.  This is the main screen which summarises all the simulations.",
	    placement: "right"
	},
	{
	    element: "#cartoon",
	    title: "Cartoon of example gene",
	    content: "Here we see a single simulation of the polymerases running along a specific gene. As the gene is so long, we have to wrap it starting from top
left to bottom right.  Damage sites are highlighted in red, and repaired sites in green.  As time progresses, polymerases are introduced and depending on the way the 
simulation has been set up, they encounter damage sites and start to queue up.  These stalled polymerases can be removed either by dissociation (in which case they are 
available for initiation again) or degraded - in either case, their exit is visualised by their falling to the bottom of the animation. Moving polymerases are also subject to
removal from the gene body by processivity.",
	    placement: "right"
	},
	{
	    element: "#cartoon_selector",
	    title: "Select which cartoon",
	    content: "We might have simulated several scenarios; we can select which one is animated in the cartoon by using this option",
	    placement: "right"
	},
	{
	    element: "#movie",
	    title: "All polymerase densities",
	    content: "Here we aggregate over many random simulations, as damage sites and repair times will vary between cells.  To speed up download times, we only present
the data every three minutes according to 'cell time'.  The colours represent the different scenarios, and all gene-lengths are presented together - we'll see later on how to 
separate these out"
	    placement: "right"
	},
	{
	    element: "#repair_stats_table",
	    title: "Repair stats",
	    content: "Here's a summary of the locations of the repair sites, and how long they'll take to be repaired, for the specific cartoon show at the top"
	    placement: "right"
	},
	{
	    element: "#params_form",
	    title: "Global settings",
	    content: "These are the values that will describe the behaviour of the cells and their polymerases.  If you hover over the row label, you will see a brief
description of what effect it will have. If you want any of the durations to be infinite (e.g. no repair) then leave that field entirely blank."
	    placement: "right"
	},
	{
	    element: "#scenarios_tab",
	    title: "Scenarios",
	    content: "Click on this tab to allow the simulation to compare different hypothetical scenarios as to how cells behave viz a viz their polymerase dynamics",
	    reflex: true, 
	    placement: "right"
	},
	{
	    element: "#scene_cards:first-child",
	    title: "Scenarios",
	    content: "Here is a specific scenario. You can change the label by clicking on the 'no_degrad' text; change the colour using the selector to the left; remove the scenario
by clicking on the 'x' icon; add a new scenario by the button at the bottom left of the page.",
	    placement: "right"
	},
	{
	    element: "#scene_cards input:first",
	    title: "Scenario values",
	    content: "These are specific values that distinguish the scenarios being simulated.  You can add and remove parameters by clicking the button at the bottom right of the page:",
	    placement: "right"
	},
	{
	    element: "#scene-footer div ",
	    title: "Scenario parameters",
	    content: "Here you can select which parameters distinguish the scenarios: click one that already distinguishes scenarios removes it, so it's takes the default value across all scenarios; click a new one
allows you then to tune it for each scenario indivually",
	    placement: "right"
	},
	{
	    element: "#genes_tab",
	    title: "Genes",
	    content: "Click on this tab to allow multiple genes to exist in the same cell."
	    reflex: true, 
	    placement: "right"
	},
	{
	    element: "#gene_cards:first-child",
	    title: "Genes",
	    content: "Here is a specific gene. These will operate in the same cell, and compete for polymerases. This is typically to allow multiple gene lengths, but heterogeneity between genes in the same cell could be modelled here.  You can weight their presence by using the 'Proportion in genome' parameter.",
	    placement: "right"
	},
	{
	    element: "#recalculate_tab",
	    title: "Run Simulation",
	    content: "Click on this tab to simulate a new set of parameters, scenarios and genes",
	    reflex: true, 
	    placement: "right"
	},
	{
	    element: "#recalculate button",
	    title: "Run Simulation",
	    content: "This button will send the parameters back to the server to run the simulation.  It may take quite a while: each scenario is simulated in turn, and a counter should progress to 100 for each. Once
completed, the animations on the previous tabs will be rebuilt, and this page will refresh with the ability to download overall stats and movie files for the simulation",
	    placement: "right"
	},
	{
	    element: "#main_tab",
	    title: "Startup Screen",
	    content: "We'll walk through the main features of the the DNA damage-repair simulator here.  This is the main screen which summarises all the simulations.",
	    placement: "right"
	}
    ]
};
