package de.delmak.fussballtipp;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.boot.registry.StandardServiceRegistry;
import org.hibernate.boot.registry.StandardServiceRegistryBuilder;
import org.hibernate.cfg.Configuration;

public class HibernateUtil
{

	private static final SessionFactory sessionFactory;
	private static final StandardServiceRegistry serviceRegistry;
	private static final ThreadLocal threadSession = new ThreadLocal();
	private static final ThreadLocal threadTransaction = new ThreadLocal();
	
	static
	{
		try
		{
                        System.out.println("Bin da.");
                        
			Configuration configuration = new Configuration();
			configuration.configure();
                        
                        String connectionUrl = System.getenv("CONNECTION_URL");
			
                        if (connectionUrl != null)
                        {
                            configuration.setProperty("hibernate.connection.url", connectionUrl);
                        }
                        
                        Class.forName("org.postgresql.Driver"); 
                        
			serviceRegistry = new StandardServiceRegistryBuilder().applySettings(configuration.getProperties()).build();  
			sessionFactory = configuration.buildSessionFactory(serviceRegistry);
		} 
		catch (Throwable ex)
		{
			System.err.println("Initial SessionFactory creation failed." + ex);
			throw new ExceptionInInitializerError(ex);
		}
	}
	
	public static Session getSession()
	{
		Session s = (Session) threadSession.get();
		
		if (s == null)
		{
			s = sessionFactory.openSession();
			threadSession.set(s);
		}
		
		return s;
	}
	
	public static void closeSession()
	{
		Session s = (Session) threadSession.get();

		threadSession.set(null);

		if ((s != null) && (s.isOpen() == true))
		{
			s.close();
		}
	}
	
	public static void beginTransaction()
	{
		Transaction tx = (Transaction) threadTransaction.get();
		
		try
		{
			if (tx == null)
			{
				tx = getSession().beginTransaction();
				threadTransaction.set(tx);
			}
		}
		catch (Exception ex)
		{
			throw ex;
		}
	}
	
	public static void commitTransaction()
	{
		Transaction tx = (Transaction) threadTransaction.get();
		
		try
		{
			if (tx != null)
			{
				tx.commit();
			}
		}
		catch (Exception ex)
		{
			throw ex;
		}
		finally
		{
			threadTransaction.set(null);
		}
	}
	
	public static void rollbackTransaction()
	{
		Transaction tx = (Transaction) threadTransaction.get();
		
		try
		{
			if (tx != null)
			{
				tx.rollback();
			}
		}
		catch (Exception ex)
		{
			throw ex;
		}
		finally
		{
			threadTransaction.set(null);
		}
	}
}
