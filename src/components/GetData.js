export async function fetchMAGData() {
    const response = await fetch("https://services.swpc.noaa.gov/json/rtsw/rtsw_mag_1m.json");
    const json = await response.json();
    return json
        .filter((d) => d.source !== "ACE")
        .map((d) => ({
        time: new Date(d.time_tag),
        bz: d.bz_gsm,
        bx: d.bx_gsm,
        by: d.by_gsm,
        bt: d.bt,
    }));
}