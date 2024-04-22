<script>
    import { page } from '$app/stores';

    let cedula = $page.url.searchParams.get('empleado');
    let docId = '';
    let nombre = '';

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
        }) } )
    }

    $: loadData();

    let borrarEmpleado = async () => {
        await fetch("http://localhost:8080/api/borrarEmpleado", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify( {cedula} )
        })
        .then( res => { res.json().then(r => {
            switch (r) {
                case 50008:
                    alert("Ocurrió un error.");
                    break;
                case 0:
                    alert(`Empleado ${nombre}, cedula ${docId}, borrado exitosamente.`);
                    window.location.href = "http://localhost:8080/listaEmpleados"
                    break;
            }
        }) } )
    }
</script>

<div class="borrarEmpleado">
    <h1>Menú de borrar empleado</h1>
    <p>¿Está seguro que desea eliminar este empleado?</p>
    <p>Valor del documento de identidad (cédula): {docId}</p>
    <p>Nombre: {nombre}</p>
    <button type="submit" on:click={borrarEmpleado}>Confirmar Borrado</button>
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