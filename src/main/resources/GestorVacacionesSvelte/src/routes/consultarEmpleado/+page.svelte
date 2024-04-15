<script>
    import { page } from '$app/stores';

    let idEmpleado = $page.url.searchParams.get('empleado');
    let docId = '';
    let nombre = '';
    let idPuesto = '';
    let saldoVacaciones = '';
</script>

<div class="consultarEmpleado">
    <h1>Menú de consultar empleado</h1>
    <p>Valor del documento de identidad (cédula): {docId}</p>
    <p>Nombre: {nombre}</p>
    <p>Puesto: {idPuesto}</p> <!-- Corregir -->
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