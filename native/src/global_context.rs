use mysql;

pub struct GlobalContext {
    pub db_pool: mysql::Pool
}

pub fn new() -> GlobalContext {
    GlobalContext {
        db_pool: mysql::Pool::new("mysql://root@localhost:3306/genginedb").unwrap()
    }
}
