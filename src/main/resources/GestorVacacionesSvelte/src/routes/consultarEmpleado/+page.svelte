<script>
    import { page } from '$app/stores';

    let cedula = $page.url.searchParams.get('empleado');
    
    let docId = '';
    let nombre = '';
    let idPuesto = '';
    let saldoVacaciones = '';

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
            idPuesto = r[0].puesto;
            saldoVacaciones = r[0].saldo;
        }) } )
    }

    $: loadData();
</script>

<div class="consultarEmpleado">
    <h1>Menú de consultar empleado</h1>
    <p>Valor del documento de identidad (cédula): {docId}</p>
    <p>Nombre: {nombre}</p>
    <p>Puesto: {idPuesto}</p> 
    <p>Saldo vacaciones: {saldoVacaciones}</p>
    <a href="/listaEmpleados">
        <button>Volver</button>
    </a>
</div>

<style>
    :global(body) {
        background-color: #979797;
        font-family: 'Franklin Gothic Medium';
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