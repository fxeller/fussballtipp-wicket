package de.delmak.fussballtipp.persistence;

import static de.delmak.fussballtipp.persistence.HibernateObject.beginTransaction;
import static de.delmak.fussballtipp.persistence.HibernateObject.commitTransaction;
import static de.delmak.fussballtipp.persistence.HibernateObject.getSession;
import static de.delmak.fussballtipp.persistence.HibernateObject.rollbackTransaction;
import java.util.Date;
import java.util.List;

public class UserPost extends HibernateObject
{

	private Integer userPostId;

	public Integer getUserPostId()
	{
		return userPostId;
	}

	public void setUserPostId(Integer userPostId)
	{
		this.userPostId = userPostId;
	}
	
	private String post;

	public String getPost()
	{
		return post;
	}

	public void setPost(String post)
	{
		this.post = post;
	}

	private Date createdate;

	public Date getCreatedate()
	{
		return createdate;
	}

	public void setCreatedate(Date createdate)
	{
		this.createdate = createdate;
	}

	private User user;

	public User getUser()
	{
		return user;
	}

	public void setUser(User user)
	{
		this.user = user;
	}

	private Betgroup betgroup;

	public Betgroup getBetgroup()
	{
		return betgroup;
	}

	public void setBetgroup(Betgroup betgroup)
	{
		this.betgroup = betgroup;
	}
	
	@Override
	public String toString()
	{
		return String.format("%s_%s_%s_%s", getClass().getName(), getUser().getUserId(), getBetgroup().getBetgroupId(), getCreatedate().toString());
	}
	
	@Override
	public boolean equals(Object obj)
	{
		return obj.toString().equals(toString());				
	}

	@Override
	public int hashCode()
	{
		return toString().hashCode();
	}
	
	public static void insert(UserPost object)
	{
		try
		{
			beginTransaction();
			getSession().save(object);
			commitTransaction();
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static void delete(UserPost object)
	{
		try
		{
			beginTransaction();
			getSession().delete(object);
			commitTransaction();
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static UserPost getById(int id)
	{
		try
		{
			beginTransaction();
			
			UserPost result = (UserPost) getSession()
					.getNamedQuery("getUserPostById")
					.setInteger("id", id)
					.uniqueResult();
			
			commitTransaction();
			
			return result;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}

	public static List getUserPostsByBetgroupId(Integer betgroupId, Integer firstResult)
	{
		try
		{
			beginTransaction();
			
			List resultRows = getSession()
					.getNamedQuery("getUserPostsByBetgroupId")
					.setInteger("betgroupId", betgroupId)
					.setFirstResult(firstResult)
					.setMaxResults(firstResult + 10)
					.list();
			
			commitTransaction();
			
			return resultRows;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static Long getUserPostCountByBetgroupId(Integer betgroupId)
	{
		try
		{
			beginTransaction();
			
			Long result = (Long) getSession()
					.getNamedQuery("getUserPostCountByBetgroupId")
					.setInteger("betgroupId", betgroupId)
					.uniqueResult();
			
			commitTransaction();
			
			return result;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}

}
