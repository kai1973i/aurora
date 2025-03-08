<script>
    import { fetchMAGData } from "./GetData.js";
    import { onMount } from "svelte";
    import * as d3 from 'd3';

    let data = [];

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

    let chartBt = {
        show: true,
        color: 'white'
    }

    let magChart;
    let bzbyChart;


    // Stunden Auswahl
    let hourList = [
        { value: 6, label: '6 Stunden' },
        { value: 12, label: '12 Stunden' },
        { value: 24, label: '24 Stunden' }
    ]
    let selectedHour = hourList[0].value;


    $: {
        drawMagChart(chartBx, chartBy, chartBz,chartBt, selectedHour);
    }

    // Daten laden
    onMount(
        async () => {
            await updateData();
            setInterval(updateData, 60000);
        }
    );

    async function updateData() {
        data = await fetchMAGData();
        drawMagChart(chartBx, chartBy, chartBz,chartBt, selectedHour);
        drawBzByChart(chartBy, chartBz);
    }

    /**
     * @param {{ show: boolean; color: string; }} [chartbx]
     * @param {{ show: boolean; color: string; }} [chartby]
     * @param {{ show: boolean; color: string; }} [chartbz]
     * @param {{ show: boolean; color: string; }} [chartbt]
     * @param {number} [selectedhour]
     */
    function drawMagChart(chartbx, chartby, chartbz, chartbt, selectedhour) {
        const margin = { top: 20, right: 30, bottom: 40, left: 40 };
        const width = 1280 - margin.left - margin.right;
        const height = 640 - margin.top - margin.bottom;

        let showbx = chartbx.show;
        let showby = chartby.show;
        let showbz = chartbz.show;
        let showbt = chartbt.show;

        let colorbz = chartbz.color;
        let colorby = chartby.color;
        let colorbx = chartbx.color;
        let colorbt = chartbt.color;

        let filteredData = data;

        let hours = selectedhour;
        
        if (hours) {
            const now = new Date();
            const timeLimit = new Date(now.getTime() - hours * 60 * 60 * 1000);
            filteredData = data.filter(d => d.time >= timeLimit);
        }


        // Remove old chart
        d3.select(magChart).selectAll('svg').remove();
        
        // Create SVG
        const svg = d3.select(magChart)
            .append('svg')
            .attr('width', width + margin.left + margin.right)
            .attr('height', height + margin.top + margin.bottom)
            .append('g')
            .attr('transform', `translate(${margin.left},${margin.top})`);

        // Create x-axis
        const x = d3.scaleTime()
            .domain(d3.extent(filteredData, d => d.time))
            .range([0, width]);

        // Find min and max values for y-axis
        let minValue = d3.min(filteredData, d => d3.min([d.bz, d.by, d.bx, d.bt]));
        if (minValue > -20) {
            minValue = -20;
        }

        let maxValue = d3.max(filteredData, d => d3.max([d.bz, d.by, d.bx, d.bt]));
        if (maxValue < 20) {
            maxValue = 20;
        }

        // Create y-axis
        const y = d3.scaleLinear()
            .domain([minValue,maxValue])
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
                    .x(filteredData => x(filteredData.time))
                    .y(filteredData => y(filteredData.bz)));
        }

        // By-chart
        if (showby) {
            svg.append('path')
                .datum(filteredData)
                .attr('fill', 'none')
                .attr('stroke', colorby)
                .attr('stroke-width', 1.5)
                .attr('d', d3.line()
                    .x(filteredData => x(filteredData.time))
                    .y(filteredData => y(filteredData.by)));
        }

        // Bx-chart
        if (showbx) {
            svg.append('path')
                .datum(filteredData)
                .attr('fill', 'none')
                .attr('stroke', colorbx)
                .attr('stroke-width', 1.5)
                .attr('d', d3.line()
                    .x(filteredData => x(filteredData.time))
                    .y(filteredData => y(filteredData.bx)));
        }

        // Bx-chart
        if (showbt) {
            svg.append('path')
                .datum(filteredData)
                .attr('fill', 'none')
                .attr('stroke', colorbt)
                .attr('stroke-width', 1.5)
                .attr('d', d3.line()
                    .x(filteredData => x(filteredData.time))
                    .y(filteredData => y(filteredData.bt)));
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


    function drawBzByChart(chartby, chartbz) {
        const margin = { top: 20, right: 30, bottom: 40, left: 40 };
        const width = 1280 - margin.left - margin.right;
        const height = 640 - margin.top - margin.bottom;

        let colorbz = chartbz.color;
        let colorby = chartby.color;

        let filteredData = data.filter(d => d.time >= new Date(new Date().getTime()));

        // Remove old chart
        d3.select(bzbyChart).selectAll('svg').remove();
        
        // Create SVG
        const svg = d3.select(bzbyChart)
            .append('svg')
            .attr('width', width + margin.left + margin.right)
            .attr('height', height + margin.top + margin.bottom)
            .append('g')
            .attr('transform', `translate(${margin.left},${margin.top})`);

        // Find min and max values for x-axis    
        let minByValue = d3.min(filteredData, d => d.by);
        if (minByValue > -20) {
            minByValue = -20;
        }
        let maxByValue = d3.max(filteredData, d => d.by);
        if (maxByValue < 20) {
            maxByValue = 20;
        }
        // Create x-axis
        const x = d3.scaleTime()
            .domain([minByValue, maxByValue])
            .nice()
            .range([0, width]); 
        
        // Find min and max values for y-axis
        let minValue = d3.min(filteredData, d => d3.min([d.bz, d.by]));
        if (minValue > -20) {
            minValue = -20;
        }

        let maxValue = d3.max(filteredData, d => d3.max([d.bz, d.by]));
        if (maxValue < 20) {
            maxValue = 20;
        }

        // Create y-axis
        const y = d3.scaleLinear()
            .domain([minValue,maxValue])
            .nice()
            .range([height, 0]);

        // Create Chart
        svg.append('g')
            .attr('class', 'x-axis')
            .attr('transform', `translate(0,${height})`)
            .call(d3.axisBottom(x));

        svg.append('g')
            .attr('class', 'y-axis')
            .call(d3.axisLeft(y));



    // Bz-chart
        svg.append('path')
            .datum(filteredData)
            .attr('fill', 'none')
            .attr('stroke', colorbz)
            .attr('stroke-width', 1.5)
            .attr('d', d3.line()
                .x(filteredData => x(filteredData.by))
                .y(filteredData => y(filteredData.bz)));
    }
                    
</script>

<style>
    #magchart {
        width: 100%;
        height: 100%;
    }
    svg {
        font-family: sans-serif;
        font-size: 10px;
    }
    .x-axis path, y-axis path { display: none;}
    #controls {
        display: flex;
        justify-content: center;
        margin-bottom: 1rem;
    }
    #controls {
        margin-right: 1rem;
        top: 0px;
    }

</style>


<div>
    <h2>ACE Sonnenwind</h2>
    <div id="magchart" bind:this={magChart}></div>
    <div id="controls">
        <div>
            <label style=color:{chartBx.color}>
                <input type="checkbox" bind:checked={chartBx.show}>
                Bx
            </label>
            <label style=color:{chartBy.color}>
                <input type="checkbox" bind:checked={chartBy.show}>
                By
            </label>                
            <label style=color:{chartBz.color}>
                <input type="checkbox" bind:checked={chartBz.show}>
                Bz
            </label>
            <label style=color:{chartBt.color}>
                <input type="checkbox" bind:checked={chartBt.show}>
                Bt
            </label>
        </div>
        <div>
            <label>
                Zeitraum:
                <select bind:value={selectedHour}>
                    {#each hourList as hour}
                        <option value={hour.value}>{hour.label}</option>
                    {/each}
                </select>
            </label>
        </div>   
    </div>    
</div>

<div id=bzbyChart bind:this={bzbyChart}>
    <h2>ACE Magnetfeld</h2>
</div>
