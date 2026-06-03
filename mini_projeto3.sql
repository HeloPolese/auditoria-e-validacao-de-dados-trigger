use `banco_financeiro`;

show triggers;

-- Trigger de validação de Dados na Tabela de Transações

	-- 1) valida o valor da transação antes de inserir

		delimiter //
		create trigger trg_transacoes
		before insert
		on Transacoes
		for each row
		begin 
			if new.valor < 0 then 
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'valor Inválido';
		end if;
		end //
		delimiter ; 

		insert into Transacoes(id_transacao,tipo,valor,data_transacao,id_conta_origem,id_conta_destino)
		values(896087687,'...',-8,'2000-02-02',2,4);
		
		
	-- 2) Valida o valor do saldo da nova conta antes de inserir
		delimiter //
		create trigger trg_valida_saldo
		before insert 
		on contas
		for each row
		begin 
			if new.saldo < 0 then 
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Saldo Inválido';
		end if;
		end //
		delimiter ;

		insert into contas(id_conta,numero_conta,saldo,data_abertura,id_agencia) values(003,453,-3,'2002-02-03',2);

-- Trigger de Automatização de preenchimento 

	-- 1) Deixa o rendimento com um valor padrao de 50 para novas contas correntes

		delimiter // 
		create trigger trg_rendimento_poupanca
		before insert
		on contaspoupancas
		for each row
		begin 
			set new.rendimento = 50;
		end //
		delimiter ;

	insert into contaspoupancas(id_conta,rendimento,data_aniversario) values(7,4,'2010-03-09');

	select *
	from contaspoupancas
	where id_conta = 7;


--  Implementação Triggers para criação de tabelas de Auditoria

	 -- 1) tabela de auditoria com log de atualizações na tabela contas

		create table log_contas(
		id_log int auto_increment,
		id_conta int,
		numero_conta int,
		saldo_antigo decimal(10,2),
		saldo_novo decimal(10,2),
		data_abertura date,
		data_atualizacao date,
				constraint id_log_pk primary key (id_log)
		)engine=innodb;

		select * from log_contas;

		delimiter //
		create trigger trg_contas_update
		after update 
		on contas
		for each row
		begin 
		insert into log_contas(
			id_conta,
			numero_conta,
			saldo_antigo,
			saldo_novo,
			data_abertura,
			data_atualizacao
		)
		values(
			old.id_conta,
			old.numero_conta,
			old.saldo,
			new.saldo,
			old.data_abertura,
			now()
		);
		end //
		delimiter ;

	update contas
	set saldo = 2000
	where id_conta = 12;

	update contas
	set saldo = 90000
	where id_conta = 80;

	update contas
	set saldo = 20
	where id_conta = 70;

	-- 2) Trigger com Auditoria de transacoes deletadas

		create table historico_transacoes(
		id_historico int auto_increment,
		id_transacao int,
		valor decimal(10,2),
		data_transacao datetime,
		id_conta_origem int,
		id_conta_destino int,
		data_transacao_deletada datetime,

		constraint id_historico_pk primary key (id_historico)

		)engine=innodb;
		
		select * from historico_transacoes;	

		
		create trigger trg_transacoes_deletadas
		before delete
		on transacoes
		for each row 
			insert into historico_transacoes(
			id_transacao,
			valor,
			data_transacao,
			id_conta_origem,
			id_conta_destino,
			data_transacao_deletada
			) values (
			old.id_transacao,
			old.valor,
			old.data_transacao,
			old.id_conta_origem,
			old.id_conta_destino,
			now()
			);

		
	delete from transacoes where id_transacao = 15;



