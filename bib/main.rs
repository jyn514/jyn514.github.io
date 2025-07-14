use{String as Str,Some as S,println as pr,unimplemented as die,matches as m,Iterator as I};
use{Option as O,std::{fs,fs::File as F,collections::BTreeMap,io::Write,iter::Peekable as Pk}};
use pulldown_cmark::{Event as E,Options as PO,Parser as P,Tag as T,TagEnd as TE,LinkType as K};
type R<O=()>=anyhow::Result<O>;type M=BTreeMap<Str,Str>;const L:&str="links.bin";
fn load()->R<M>{Ok(fs::read_to_string(L)?.lines().flat_map(|l|{
	let(k,v)=l.split_once('\0')?;S((k.into(),v.into()))
}).collect())}
fn save(m:&M)->R{let mut fd=F::create(L)?;for(k,v)in m{
	fd.write_all(k.as_bytes())?;fd.write_all(b"\0")?;fd.write_all(v.as_bytes())?;fd.write_all(b"\n")?;
}fd.flush().map_err(Into::into)}
fn main()->R{let mut m=load().unwrap_or_default();let ps=std::env::args().skip(1).map(|a|
	R::Ok(post(&std::fs::read_to_string(&a)?,&mut m))
).collect::<R<Vec<_>>>()?;save(&m)?;for p in ps{
	pr!("---\n## bibliography\n");for l in p{pr!("- [{}]({l})",m[&l])}
}Ok(())}
fn bib(e:O<&E>)->bool{m!(e,S(E::Text(t))if t.eq_ignore_ascii_case("bibliography"))}
fn name<'a>(t:&mut Str,id:&str,k:K,p:&mut Pk<impl I<Item=E<'a>>>){
	if k==K::Inline{for e in p.by_ref().take_while(|e|!m!(e,E::End(TE::Link{..}))){
		match e{E::Text(nt)=>*t+=&nt,E::Code(nt)=>*t+=&nt,
			E::SoftBreak|E::Start(..)|E::End(..)=>{},o=>{die!("{o:?}: {t} {id}")}
	}}}if t.is_empty(){*t+=id}}
fn post(src:&str,m:&mut M)->Vec<Str>{let mut p=P::new_ext(src,PO::all()).peekable();
	let mut b=false;let mut v=vec![];while let S(e)=p.next(){
		if m!(e,E::Start(T::Heading{..})){b=bib(p.peek())}else if m!(e,E::Start(T::FootnoteDefinition(..))){b=false}
		let E::Start(T::Link{link_type:ty,dest_url:d,title:t,id})=e else{continue};
		if!d.starts_with("http"){continue;}
		let mut t=t.into();let k=d.split_once('#').map_or(d.to_string(),|t|t.0.to_string());name(&mut t,&id,ty,&mut p);
		if b{m.insert(k,t);}else{m.entry(k.clone()).or_insert(t);v.push(k);}}v}
