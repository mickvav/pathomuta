create database mutfreq;
CREATE USER 'mutfreq'@'localhost' IDENTIFIED BY 'mutfreq';
GRANT ALL ON mutfreq.* to 'mutfreq'@'localhost';
create table `rs` (`rsId` int(11) unsigned not null,`Symbol` varchar(100),`geneId` varchar(100),`Frequency` Float(7,4) );
alter table `rs` add   PRIMARY KEY (`rsId`);
create table `rshgvs` (`rsId` int(11) unsigned not null,`hgvs` varchar(100));

