function value = move(obj, key, db)

R=obj.redis;

__redisWrite(R, 'MOVE', key, db);
value = __redisRead(R, 5000);

if !strcmp(value,":1\r\n")
  sprintf('WARNING: Failed to move key %s to database %d!', key, db)
end
