import{s as x,n as u,b as S}from"../chunks/scheduler.BvLojk_z.js";import{S as j,i as k,e as h,b as d,s as q,c as v,d as b,f as g,g as m,h as y,j as _,k as E,l as $}from"../chunks/index.CIuBr4bG.js";import{p as C}from"../chunks/stores.CL86yiWF.js";function H(p){var f;let a,t=p[0].status+"",r,o,n,i=((f=p[0].error)==null?void 0:f.message)+"",c;return{c(){a=h("h1"),r=d(t),o=q(),n=h("p"),c=d(i)},l(e){a=v(e,"H1",{});var s=b(a);r=g(s,t),s.forEach(m),o=y(e),n=v(e,"P",{});var l=b(n);c=g(l,i),l.forEach(m)},m(e,s){_(e,a,s),E(a,r),_(e,o,s),_(e,n,s),E(n,c)},p(e,[s]){var l;s&1&&t!==(t=e[0].status+"")&&$(r,t),s&1&&i!==(i=((l=e[0].error)==null?void 0:l.message)+"")&&$(c,i)},i:u,o:u,d(e){e&&(m(a),m(o),m(n))}}}function P(p,a,t){let r;return S(p,C,o=>t(0,r=o)),[r]}class B extends j{constructor(a){super(),k(this,a,P,H,x,{})}}export{B as component};
