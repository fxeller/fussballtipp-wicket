package de.delmak.fussballtipp.persistence;

import de.delmak.fussballtipp.HibernateUtil;
import java.io.Serializable;
import org.hibernate.Session;
import org.hibernate.Transaction;

public class HibernateObject implements Serializable
{

	public static Session getSession()
	{
		return HibernateUtil.getSession();
	}		
	
	public static void beginTransaction()
	{
		HibernateUtil.beginTransaction();
	}
	
	public static void commitTransaction()
	{
		HibernateUtil.commitTransaction();
	}
	
	public static void rollbackTransaction()
	{
		HibernateUtil.rollbackTransaction();
	}
}
