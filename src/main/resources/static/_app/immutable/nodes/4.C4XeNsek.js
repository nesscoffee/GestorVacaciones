import{s as O,n as B,b as U}from"../chunks/scheduler.BvLojk_z.js";import{S as w,i as F,e as r,s as u,b as x,c as d,d as I,m as b,h,f as _,g as C,n as g,j as G,k as t,q as J}from"../chunks/index.CIuBr4bG.js";import{p as K}from"../chunks/stores.CL86yiWF.js";function Q(f){let e,l,c="Menú de borrar empleado",v,o,L="¿Está seguro que desea eliminar este empleado?",E,i,y,P,T,p,V,k,q,s,S="Confirmar Borrado",H,n,j='<button class="svelte-1gyia2h">Volver</button>',M,z;return{c(){e=r("div"),l=r("h1"),l.textContent=c,v=u(),o=r("p"),o.textContent=L,E=u(),i=r("p"),y=x("Valor del documento de identidad (cédula): "),P=x(A),T=u(),p=r("p"),V=x("Nombre: "),k=x(D),q=u(),s=r("button"),s.textContent=S,H=u(),n=r("a"),n.innerHTML=j,this.h()},l(m){e=d(m,"DIV",{class:!0});var a=I(e);l=d(a,"H1",{"data-svelte-h":!0}),b(l)!=="svelte-nczex6"&&(l.textContent=c),v=h(a),o=d(a,"P",{"data-svelte-h":!0}),b(o)!=="svelte-12xr8km"&&(o.textContent=L),E=h(a),i=d(a,"P",{});var N=I(i);y=_(N,"Valor del documento de identidad (cédula): "),P=_(N,A),N.forEach(C),T=h(a),p=d(a,"P",{});var $=I(p);V=_($,"Nombre: "),k=_($,D),$.forEach(C),q=h(a),s=d(a,"BUTTON",{type:!0,class:!0,"data-svelte-h":!0}),b(s)!=="svelte-s7ip8c"&&(s.textContent=S),H=h(a),n=d(a,"A",{href:!0,"data-svelte-h":!0}),b(n)!=="svelte-1betxxr"&&(n.innerHTML=j),a.forEach(C),this.h()},h(){g(s,"type","submit"),g(s,"class","svelte-1gyia2h"),g(n,"href","/listaEmpleados"),g(e,"class","borrarEmpleado")},m(m,a){G(m,e,a),t(e,l),t(e,v),t(e,o),t(e,E),t(e,i),t(i,y),t(i,P),t(e,T),t(e,p),t(p,V),t(p,k),t(e,q),t(e,s),t(e,H),t(e,n),M||(z=J(s,"click",f[0]),M=!0)},p:B,i:B,o:B,d(m){m&&C(e),M=!1,z()}}}let A="",D="";function R(f,e,l){let c;return U(f,K,o=>l(1,c=o)),c.url.searchParams.get("empleado"),[()=>{}]}class Z extends w{constructor(e){super(),F(this,e,R,Q,O,{})}}export{Z as component};
