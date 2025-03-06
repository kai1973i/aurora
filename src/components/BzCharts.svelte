<script>
    import { fetchMAGData } from "./GetData.js";
    import { onMount } from "svelte";
    import * as d3 from 'd3';

    let data = [];
    let selectedHours = 24;


    let chartBz = {
        show: true,
        color: 'red'
    };

    let chartBy = {
        show: false,
        color: 'green'
    };

    let chartBx = {
        show: false,
        color: 'yellow'
    };


    $: {
        drawChart(chartBz, chartBy, chartBx, selectedHours);
    }

    onMount(
        async () => {
            data = await fetchMAGData();
            drawChart(chartBx, chartBy, chartBz);
        }
    );

    /**
     * @param {{ show: boolean; color: string; }} [chartbx]
     * @param {{ show: boolean; color: string; }} [chartby]
     * @param {{ show: boolean; color: string; }} [chartbz]
     * @param {number} [hours]
     */
    function drawChart(chartbx, chartby, chartbz, hours) {
        const margin = { top: 20, right: 30, bottom: 40, left: 40 };
        const width = 1280 - margin.left - margin.right;
        const height = 640 - margin.top - margin.bottom;

        let showbz = chartbx.show;
        let showby = chartby.show;
        let showbx = chartbz.show;

        let colorbz = chartbz.color;
        let colorby = chartby.color;
        let colorbx = chartbx.color;

        let filteredData = data;

        let selectedHours = hours;
        
        if (selectedHours) {
            const now = new Date();
            const timeLimit = new Date(now.getTime() - selectedHours * 60 * 60 * 1000);
            filteredData = data.filter(d => d.time >= timeLimit);
        }


        d3.select('#chart').selectAll('svg').remove();

        const svg = d3.select('#chart')
            .append('svg')
            .attr('width', width + margin.left + margin.right)
            .attr('height', height + margin.top + margin.bottom)
            .append('g')
            .attr('transform', `translate(${margin.left},${margin.top})`);

        const x = d3.scaleTime()
            .domain(d3.extent(filteredData, d => d.time))
            .range([0, width]);

        const y = d3.scaleLinear()
            .domain([d3.min(filteredData, d => d.bz), d3.max(data, d => d.bz)])
            .nice()
            .range([height, 0]);

        svg.append('g')
            .attr('class', 'x-axis')
            .attr('transform', `translate(0,${height})`)
            .call(d3.axisBottom(x));

        svg.append('g')
            .attr('class', 'y-axis')
            .call(d3.axisLeft(y));



        // Bz-chart
        if (showbz) {
            svg.append('path')
                .datum(filteredData)
                .attr('fill', 'none')
                .attr('stroke', colorbz)
                .attr('stroke-width', 1.5)
                .attr('d', d3.line()
                    .x(d => x(d.time))
                    .y(d => y(d.bz)));
        }

        // By-chart
        if (showby) {
            svg.append('path')
                .datum(filteredData)
                .attr('fill', 'none')
                .attr('stroke', colorby)
                .attr('stroke-width', 1.5)
                .attr('d', d3.line()
                    .x(d => x(d.time))
                    .y(d => y(d.by)));
        }

        // Bx-chart
        if (showbx) {
            svg.append('path')
                .datum(filteredData)
                .attr('fill', 'none')
                .attr('stroke', colorbx)
                .attr('stroke-width', 1.5)
                .attr('d', d3.line()
                    .x(d => x(d.time))
                    .y(d => y(d.bx)));
        }

        // Zero-line
        svg.append('path')
            .datum(filteredData)
            .attr('fill', 'none')
            .attr('stroke', 'steelblue')
            .attr('stroke-width', 1.5)
            .attr('d', d3.line()
                .x(d => x(d.time))
                .y(d => y(0)));
    }
</script>

<style>
    #chart {
        width: 100%;
        height: 100%;
    }
    svg {
        font-family: sans-serif;
        font-size: 10px;
    }
    .x-axis path, y-axis path { display: none;}
</style>


<div id="chart"></div>

<div>
    <label>
        <input type="checkbox" bind:checked={chartBz.show}>
        Bz Chart anzeigen
    </label>
    <label>
        <input type="checkbox" bind:checked={chartBy.show}>
        By Chart anzeigen
    </label>
    <label>
        <input type="checkbox" bind:checked={chartBx.show}>
        Bx Chart anzeigen
    </label>
</div>
<div>
    <label>
        Zeitraum:
        <select bind:value={selectedHours}>
            <option value="6">6 Stunden</option>
            <option value="12">12 Stunden</option>
            <option value="24">24 Stunden</option>
        </select>
    </label>
</div>
