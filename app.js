const views=[...document.querySelectorAll('section')],links=[...document.querySelectorAll('aside a')];
function show(){const id=(location.hash||'#dashboard').slice(1);
views.forEach(s=>s.classList.toggle('on',s.id===id));links.forEach(a=>a.classList.toggle('on',a.hash==='#'+id));}
addEventListener('hashchange',show);show();
const chat=document.getElementById('chat'),msgs=document.getElementById('msgs');
document.getElementById('chatBtn').onclick=()=>chat.classList.toggle('on');
document.getElementById('chatForm').onsubmit=e=>{e.preventDefault();const i=e.target.q,t=i.value.trim();if(!t)return;
add(t,'me');i.value='';setTimeout(()=>add('The assistant is not connected yet. Once the Gemini backend is added, answers will appear here.','bot'),400);};
function add(t,c){const d=document.createElement('div');d.className='m '+c;d.textContent=t;msgs.appendChild(d);msgs.scrollTop=msgs.scrollHeight;}
