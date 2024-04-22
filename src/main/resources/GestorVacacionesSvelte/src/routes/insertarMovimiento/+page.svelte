<script>
    import { page } from '$app/stores';

    let cedula = $page.url.searchParams.get('empleado');
    let tipoMovimiento = '';
    let monto = '';
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
            saldoVacaciones = r[0].saldo;
        }) } )
    }

    $: loadData();

    let insertarMovimiento = async () => {
        let montoFloat = parseFloat(monto);
        if ( (parseFloat(saldoVacaciones) - parseFloat(monto)) < 0 
        && (tipoMovimiento == "Disfrute de vacaciones"
        || tipoMovimiento == "Venta de vacaciones"
        || tipoMovimiento == "Reversion de Credito") ) {
            alert("El monto ingresado hace el saldo negativo.")
        } else if (parseFloat(monto) < 0) {
            alert("El monto ingresado es negativo.")
        } else {
            await fetch("http://localhost:8080/api/insertarMovimiento", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify( { cedula, tipoMovimiento, montoFloat } )
            })
            .then( res => { res.json().then(r => {
                switch (r) {
                    case 50014:
                        alert("Monto ingresado es negativo.");
                        break;
                    case 50011:
                        alert("El monto ingresado hace el saldo muy negativo.");
                        break;
                    case 50008:
                        alert("Un error interno en la base de datos ocurrio.")
                        break;
                    case 0:
                        alert("Movimiento insertado con exito.")
                        window.location.href = "http://localhost:8080/listaEmpleados"
                        break;
                }
            }) } )
        }
    }

</script>

<div class="insertarMovimiento">
    <h1>Menú de insertar movimiento</h1>
    <div class="inputs">
        <label for="tipoMov">Tipo de movimiento:</label>
        <select name="tipoMov" id="tipoMov" bind:value={tipoMovimiento}>
            <option value="Cumplir mes">Cumplir mes</option>
            <option value="Bono vacacional">Bono vacacional</option>
            <option value="Disfrute de vacaciones">Disfrute de vacaciones</option>
            <option value="Venta de vacaciones">Venta de vacaciones</option>
            <option value="Reversion Debito">Reversion Debito</option>
            <option value="Reversion de Credito">Reversion Credito</option>
        </select>
        <label for="tipoMov" style="color: red;">*</label>
            <br>
        <label for="monto">Monto:</label>
        <input type="text" id="monto" required bind:value={monto}>
        <label for="monto" style="color: red;">*</label>
            <br>
        <button type="submit" on:click={insertarMovimiento}>Insertar Movimiento</button>
        <a href="/listaEmpleados">
            <button>Volver</button>
        </a>
    </div>
</div>

<style>
    :global(body) {
        background-color: #979797;
        font-family: 'Franklin Gothic Medium';
    }

    input:invalid {
        border-color: red;
        border-width: 3px;
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