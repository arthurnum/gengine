use global_context::{self, GlobalContext};

pub struct Player {
  name: String
}

#[test]
fn test_db() {
    let globalContext = global_context::new();
    assert_eq!(false, find_player(&globalContext, "arthur".to_string()));
    assert_eq!(true, find_player(&globalContext, "arthurnum".to_string()));
}

pub fn find_player(context: &GlobalContext, plname: String) -> bool {
  let execution = context.db_pool.prep_exec("select * from players where name = ? limit 1", (plname,)).unwrap();

  let data: Vec<Player> = execution.map( |u_result| {
      let mut result = u_result.unwrap();

      let x: String = result.take::<String, &str>("name").unwrap();

      Player { name: x }
    }
  ).collect();

  data.len() > 0
}
