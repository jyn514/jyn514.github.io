type R=anyhow::Result<()>;use{Iterator as I,println as pr, unimplemented as die};
use pulldown_cmark::{Event as E,Options as O,Parser as P,Tag as T,TagEnd as TE,LinkType as K};

fn main()->R{for a in std::env::args().skip(1){f(&std::fs::read_to_string(&a)?);}Ok(())}
fn f(src:&str){let mut p=P::new_ext(src,O::all());
	pr!("---\n## bibliography\n");
	while let Some(e)=p.next(){
		if let E::Start(T::Link{link_type:k,dest_url:d,title:t,id})=e{
			if!d.starts_with("http"){continue;}
			let mut t=t.into_string();//pr!("{k:?} {d} {t} {id}");
			if k==K::Inline{for e in p.by_ref().take_while(|e|!matches!(e,E::End(TE::Link{..}))){
				match e{E::Text(nt)=>t+=&nt,E::Code(nt)=>t+=&nt,
					E::SoftBreak|E::Start(..)|E::End(..)=>{},o=>{die!("{o:?}: {d} {t} {id}")}
			}}}
			if t.is_empty(){t=id.to_string()}
			pr!("- [{t}]({d})");
}}}
