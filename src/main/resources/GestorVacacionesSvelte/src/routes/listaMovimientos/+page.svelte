<script>
    import { page } from '$app/stores';

    let cedula = $page.url.searchParams.get('empleado');
    
    let docId = '';
    let nombre = '';
    let saldoVacaciones = '';
    let movimientos = [];

    let loadData = async () => {
        await fetch("http://localhost:8080/api/getInfoEmpleado", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify( {cedula} )
        })
        .then( res => { res.json().then(r => {
            docId = r[0].cedula;
            nombre = r[0].nombre;
            saldoVacaciones = r[0].saldo;
        }) } )
    }

    let loadMovimientos = async () => {
        await fetch("http://localhost:8080/api/getListaMovimientos", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify( {cedula} )
        })
        .then( res => { res.json().then(r => {
            movimientos = r;
        }) } )
    }

    $: loadData();
    $: loadMovimientos();


</script>

<div class="consultarEmpleado">
    <h1>Menú de consultar movimientos de empleado</h1>
    <p>Valor del documento de identidad (cédula): {docId}</p>
    <p>Nombre: {nombre}</p>
    <p>Saldo vacaciones: {saldoVacaciones}</p>
    <table>
        <tr>
            <th>Fecha</th>
            <th>Tipo de movimiento</th>
            <th>Monto</th>
            <th>Nuevo saldo</th>
            <th>Usuario</th>
            <th>IP</th>
            <th>Timestamp</th>
        </tr>
        {#each movimientos as movimiento}
        <tr>
            <td>{movimiento.fecha}</td>
            <td>{movimiento.nombreMovimiento}</td>
            <td>{movimiento.monto}</td>
            <td>{movimiento.nuevoSaldo}</td>
            <td>{movimiento.username}</td>
            <td>{movimiento.ip}</td>
            <td>{new Date(movimiento.estampa).toLocaleString("es-CR") }</td>
        </tr>
        {/each}
    </table>
    <a href="/listaEmpleados">
        <button>Volver</button>
    </a>
</div>

<style>
    :global(body) {
        background-color: #979797;
        font-family: 'Franklin Gothic Medium';
    }

    table, th, td {
        margin-top: 15px;
        border: 1px solid black;
        border-collapse: collapse;
        padding: 10px;
    }

    button {
        margin-top: 20px;
        background-color: #d0d0d0;
        border: none;
        padding: 5px;
        border-radius: 5px;
    }

    button:hover {
        background-color: #585858;
        cursor: pointer;
    }
</style>