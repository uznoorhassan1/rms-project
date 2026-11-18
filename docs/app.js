const role=sessionStorage.getItem('role');if(!role)location.replace('login.html');
const names={manager:'Ayesha, Manager',waiter:'Bilal, Waiter',chef:'Imran, Chef',customer:'Hamza, Customer'};
const home={manager:'dashboard',waiter:'floor',chef:'kitchen',customer:'myres'};
document.getElementById('who').textContent=names[role]||'';
document.getElementById('out').onclick=()=>sessionStorage.removeItem('role');
const ok=el=>(el.dataset.roles||'').split(' ').includes(role);
const views=[...document.querySelectorAll('section')].filter(ok),links=[...document.querySelectorAll('aside nav a')];
links.forEach(a=>a.style.display=ok(a)?'':'none');
function show(){let id=(location.hash||'#'+home[role]).slice(1);if(!views.some(s=>s.id===id))id=home[role];
document.querySelectorAll('section').forEach(s=>s.classList.toggle('on',s.id===id));links.forEach(a=>a.classList.toggle('on',a.hash==='#'+id));}
addEventListener('hashchange',show);show();
const chat=document.getElementById('chat'),msgs=document.getElementById('msgs');
document.getElementById('chatBtn').onclick=()=>chat.classList.toggle('on');
document.getElementById('chatForm').onsubmit=e=>{e.preventDefault();const i=e.target.q,t=i.value.trim();if(!t)return;
add(t,'me');i.value='';setTimeout(()=>add('The assistant is not connected yet. Once the Gemini backend is added, answers will appear here.','bot'),400);};
function add(t,c){const d=document.createElement('div');d.className='m '+c;d.textContent=t;msgs.appendChild(d);msgs.scrollTop=msgs.scrollHeight;}
